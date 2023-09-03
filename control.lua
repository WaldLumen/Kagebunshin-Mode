require("clones")
require("player")
require("area")
require("button")
-- Define the distance in tiles in front of the player





-- Define the entities you want to consider
local entities_to_consider = { "tree", "big_rock", "enemy" } -- Add other entity names as neededkagebunshin = {}


kagebunshins_cords = {}
kagebunshins = {}


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


script.on_event(defines.events.on_tick,
        function(event)
            --Узнаём путь до близжайсшего чанка(внести  в отдельное событие.)


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