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

function create_new_character_behind_player(player, direction)
    local player_position = player.position
    local offset = {x = -1, y = 0}  -- You can adjust the offset as needed
    local new_position = {x = player_position.x + offset.x, y = player_position.y + offset.y}

    surface = player.surface

    -- Spawn a new character
    local new_character = surface.create_entity{
        name = "character",  -- Replace with the actual character entity name
        position = new_position,
        force = player.force
    }
    -- Attach the new character to the player character
    -- player.character = new_character
    new_character.walking_state = {walking = true, direction = direction}

    new_character.character_running_speed_modifier = settings.global["clone_speed"].value

    return new_character
end

function create_character(player, direction)
    new_character = create_new_character_behind_player(player, direction)
    kagebunshins[new_character] = new_character
end

function delete_character(character)
    character.destroy()
    kagebunshins[character] = nil
    kagebunshins_cords[character] = nil
end

function obstacle_avoidance(character)
    character.walking_state = {walking=true, direction = defines.direction.south}
end






-- updates the map for one character
--
function update_chart (character)

    local radius = 100  -- Adjust the exploration radius as needed

    character.force.chart(character.surface, {
        {character.position.x-radius, character.position.y-radius},
        {character.position.x+radius, character.position.y+radius}
    })
end

function spawn_trail(character)
    local trail_particles = settings.global["trail-particles"].value

    local particle_entities = {
        ["fire"] = {"fire-flame"},
        ["poison"] = {"poison-cloud-visual-dummy"},
        ["all"] = {"fire-flame", "poison-cloud-visual-dummy"}
    }

    if settings.global["trail-particles"].value == "off" then
        return
    else
        local entities_to_spawn = particle_entities[trail_particles]
        for _, entity_name in ipairs(entities_to_spawn) do
            character.surface.create_entity{name=entity_name, position=character.position, force="neutral"}
        end

    end
end



return {
    delete_character = delete_character,
    create_character = create_character,
    create_new_character_behind_player = create_new_character_behind_player,
    is_character_moved = is_character_moved,
    obstacle_avoidance = obstacle_avoidance,
    update_chart = update_chart,
    getDirectionToNearestChunk = getDirectionToNearestChunk
}