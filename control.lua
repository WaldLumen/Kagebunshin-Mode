local clones = require("clones")
local _player = require("player")
local area = require("area")
-- Define the distance in tiles in front of the player


-- Define the entities you want to consider
local entities_to_consider = { "tree", "big_rock", "enemy" } -- Add other entity names as neededkagebunshin = {}


kagebunshins_cords = {}
kagebunshins = {}
chunks = {}
_direction = nil

function spawn_trail(character)
    local trail_particles = settings.global["trail-particles"].value

    local particle_entities = {
        ["fire"] = {"fire-flame"},
        ["poison"] = {"poison-cloud-visual-dummy"},
        ["all"] = {"fire-flame", "poison-cloud-visual-dummy"}
    }

    local entities_to_spawn = particle_entities[trail_particles]
            for _, entity_name in ipairs(entities_to_spawn) do
                character.surface.create_entity{name=entity_name, position=character.position, force="neutral"}
            end
    
end

function tprint (tbl, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2
    for k, v in pairs(tbl) do
        toprint = toprint .. string.rep(" ", indent)
        if (type(k) == "number") then
            toprint = toprint .. "[" .. k .. "] = "
        elseif (type(k) == "string") then
            toprint = toprint  .. k ..  "= "
        end
        if (type(v) == "number") then
            toprint = toprint .. v .. ",\r\n"
        elseif (type(v) == "string") then
            toprint = toprint .. "\"" .. v .. "\",\r\n"
        elseif (type(v) == "table") then
            toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
        else
            toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
        end
    end
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    return toprint
end

script.on_event(defines.events. on_chunk_generated,
        function(event)
            local playerPosition = game.players[1] .position
            local ex = findEdgeExploredChunks(game.surfaces["nauvis"])
            local nearestChunk = getNearestChunkToPlayer(playerPosition, ex)
            _direction = getDirectionToNearestChunk(playerPosition, nearestChunk)

        end
)

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
                        clones.create_character(player, _direction)
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