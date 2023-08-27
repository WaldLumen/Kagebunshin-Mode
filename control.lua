local clones = require("clones")
local _player = require("player")

-- Define the distance in tiles in front of the player


-- Define the entities you want to consider
local entities_to_consider = { "tree", "big_rock", "enemy" } -- Add other entity names as neededkagebunshin = {}


kagebunshins_cords = {}
kagebunshins = {}

function spawn_trail(character)
    local actions = {
        ['fire'] = function() character.surface.create_entity{name="fire-flame", position=character.position, force="neutral"} end,
        ['poison'] = function() character.surface.create_entity{name="poison-cloud-visual-dummy", position=character.position, force="neutral"} end,
        ['all'] = function()
            character.surface.create_entity{name="poison-cloud-visual-dummy", position=character.position, force="neutral"}
            character.surface.create_entity{name="fire-flame", position=character.position, force="neutral"}
        end
    }

    local selected_action = actions[settings.global["trail-particles"].value]
    return selected_action() or 'Unknown action'
end

script.on_event(defines.events.on_tick,
        function(event)
            if event.tick % 1 == 0  then
                for _, character in pairs(kagebunshins) do
                    if character.valid then -- hack cuz stupid race conditions
                        clones.update_chart(character)
                        if settings.global["trail-for-unit"].value == "clones" or settings.global["trail-for-unit"].value =="all" then
                            spawn_trail(character)
                        end
                        if not clones.is_character_moved(character) then
                            obstacle_avoidance(character)
                            clones.delete_character(character)
                        end
                    end
                end

                -- Interrupts execution of further code if run is not true
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
                    local front_position = _player.calculate_front_position(position, direction)

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
                        clones.create_character(player)

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