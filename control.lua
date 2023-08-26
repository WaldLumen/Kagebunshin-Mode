

-- Define the distance in tiles in front of the player
local distance_in_front = 1

-- Define the entities you want to consider
local entities_to_consider = { "tree", "big_rock", "enemy" } -- Add other entity names as neededkagebunshin = {}


kagebunshins_cords = {}
kagebunshins = {}



function spawn_trail(character)
    local trail_particles = settings.global["trail-particles"].value
        if trail_particles == "fire" then
            character.surface.create_entity{name="fire-flame", position=character.position, force="neutral"};
        end

        if trail_particles == "poison" then
            character.surface.create_entity{name="poison-cloud-visual-dummy", position=character.position, force="neutral"};
        end

        if trail_particles == "all" then
            character.surface.create_entity{name="fire-flame", position=character.position, force="neutral"};
            character.surface.create_entity{name="poison-cloud-visual-dummy", position=character.position, force="neutral"};
        end

end

-- returns true if the character moved and false if not
function is_character_moved(character)
    if not kagebunshins_cords[character] then
        kagebunshins_cords[character] = {
            old_x = character.position.x,
            old_y = character.position.y
        }
        return true
    end
    local cords = kagebunshins_cords[character]
    if not (cords.x or cords.y) then
        cords.x = character.position.x
        cords.y = character.position.y
        return true
    end
    is_moved = not (cords.old_x == cords.x and cords.old_y == cords.y)
    cords.old_x = cords.x
    cords.old_y = cords.y
    cords.x = character.position.x
    cords.y = character.position.y
    return is_moved
end

-- updates the map for one character
function update_chart (character)
        local radius = 2  -- Adjust the exploration radius as needed

        local exploration_radius = 2  -- Adjust the exploration radius as needed
        --surface.request_to_generate_chunks(new_character.position, exploration_radius)
        --surface.force_generate_chunk_requests()

        character.force.chart(character.surface, {
            {character.position.x-radius, character.position.y-radius},
            {character.position.x+radius, character.position.y+radius}
        })
end

-- calculates the position in front of the player in order to check if there are creatures from the list "entities_to_consider"
function calculate_front_position(position, direction)
    if direction == defines.direction.north then
        front_position = { x = position.x, y = position.y - distance_in_front }
    elseif direction == defines.direction.east then
        front_position = { x = position.x + distance_in_front, y = position.y }
    elseif direction == defines.direction.south then
        front_position = { x = position.x, y = position.y + distance_in_front }
    elseif direction == defines.direction.west then
        front_position = { x = position.x - distance_in_front, y = position.y }
    elseif direction == defines.direction.northeast then
        front_position = { x = position.x + distance_in_front, y = position.y - distance_in_front }
    elseif direction == defines.direction.southeast then
        front_position = { x = position.x + distance_in_front, y = position.y + distance_in_front }
    elseif direction == defines.direction.southwest then
        front_position = { x = position.x - distance_in_front, y = position.y + distance_in_front }
    elseif direction == defines.direction.northwest then
        front_position = { x = position.x - distance_in_front, y = position.y - distance_in_front }


    end
    return front_position
end

function create_new_character_behind_player(player)
    local player_position = player.position
    local offset = {x = -1, y = 0}  -- You can adjust the offset as needed
    local new_position = {x = player_position.x + offset.x, y = player_position.y + offset.y}

    surface = player.character.surface

    -- Spawn a new character
    local new_character = surface.create_entity{
        name = "character",  -- Replace with the actual character entity name
        position = new_position,
        force = player.force
    }
    -- Attach the new character to the player character
    -- player.character = new_character

    local walking_state = player.character.walking_state
    if walking_state then
        new_character.walking_state = walking_state
        new_character.character_running_speed_modifier = settings.global["clone_speed"].value
    end
    return new_character
end

function create_character(player)
    new_character = create_new_character_behind_player(player)
    kagebunshins[new_character] = new_character
end

function delete_character(character)
    character.destroy()
    kagebunshins[character] = nil
    kagebunshins_cords[character] = nil
end

script.on_event(defines.events.on_entity_died,
        function(event)
            print("entity died", event.entity.name)
            delete_character(event.entity)
        end
)

script.on_event(defines.events.on_tick,
        function(event)
            if event.tick % 1 == 0  then
                for _, character in pairs(kagebunshins) do
                    if character.valid then -- hack cuz stupid race conditions
                        update_chart(character)
                        if settings.global["trail-for-unit"].value == "clones" or settings.global["trail-for-unit"].value =="all" then
                            spawn_trail(character)
                        end
                        if not is_character_moved(character) then
                            delete_character(character)
                        end
                    end
                end

                if not settings.global["run"].value then
                    return
                end

                for _, player in pairs(game.players) do
                    if not player.connected then
                        repeat -- lua doesn't have a continue statement, so we use this hack
                            do break end -- goes to next iteration of for
                        until true
                    end

                    local character = player.character

                    if not character then
                        return
                    end

                    local position = character.position
                    local direction = character.direction
                    local front_position = calculate_front_position(position, direction)

                    -- Find entities in the area in front of the player
                    local entities_in_front = player.surface.find_entities_filtered{
                        area = {
                            { x = front_position.x - 0.5, y = front_position.y - 0.5 },
                            { x = front_position.x + 0.5, y = front_position.y + 0.5 }
                        },
                        type = entities_to_consider
                    }

                    -- Now you can process the found entities, like breaking them
                    for _, entity in pairs(entities_in_front) do
                        -- entity.destroy()
                        player.mine_entity(entity)

                        -- add character to list, so we can update the map later
                        create_character(player)

                    end
                end
            end
        end
)

script.on_event(defines.events.on_player_changed_position,
        function(event)
            local character = game.get_player(event.player_index)
            if settings.global["trail-for-unit"].value == "player" or settings.global["trail-for-unit"].value =="all" then
                spawn_trail(character)
            end
        end
)