_direction = nil
mod_gui = require('mod-gui')

-- Создаем новую кнопку
local function createHelloButton(player)
    local button_flow = mod_gui.get_button_flow(player)
    local button = button_flow["kagebunshins_spawn"]
    if not (button and button.valid) then
        button = button_flow.add{
            type = "button",
            name = "kagebunshins_spawn",
            caption = {"kagebunshin-gui.caption"},
            tooltip = {"kagebunshin-gui.tooltip"}
        }
    end
    return button

end

-- Обработчик нажатия кнопки
local function onButtonClick(player)
    local playerPosition = player.position
    local ex = findEdgeExploredChunks(game.surfaces["nauvis"])
    local nearestChunk = getNearestChunkToPlayer(playerPosition, ex)
    _direction = getDirectionToNearestChunk(playerPosition, nearestChunk)

    create_character(player, _direction)
    end

-- Регистрируем кнопку и обработчик события
script.on_event(defines.events.on_player_joined_game,
        function(event)
    local player = game.players[event.player_index]
    if player and player.valid then
        createHelloButton(player)
    end
end)

script.on_event(defines.events.on_console_command,
        function(event)
            local player = game.players[event.player_index]
            local command = event.command
            if player and player.valid then
                if command == "spawn_button" then
                    createHelloButton(player)
                end
            end
        end)


script.on_event(defines.events.on_gui_click,
        function(event)
    if event.element and event.element.name == "kagebunshins_spawn" then
        onButtonClick(game.players[event.player_index])
    end
end)

