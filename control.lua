require("clones/clones")
require("clones/player")
require("clones/area")
require("clones/direction")
require("buttons/spawn_clone_button")
-- Define the distance in tiles in front of the player

kagebunshins_cords = {}
kagebunshins = {}


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