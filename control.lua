script.on_event(defines.events.on_player_changed_position,
        function(event)
            local player = game.get_player(event.player_index)
            if settings.global["isfire"].value then
                player.surface.create_entity{name="fire-flame", position=player.position, force="neutral"};
            end
        end
)

script.on_event(defines.events.on_player_changed_position,
        function(event)
            local player = game.get_player(event.player_index)
            if settings.global["issmoke"].value then
                player.surface.create_entity{name="smoke", position=player.position, force="neutral"};
            end
        end
)

