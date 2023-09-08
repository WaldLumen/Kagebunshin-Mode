_direction = nil

-- Создаем новую кнопку
local function createHelloButton(player)
    local button = player.gui.top["kagebunshins_spawn"]
    if not (button and button.valid) then
        button = player.gui.top.add{
            type = "button",
            name = "kagebunshins_spawn",
            caption = "Clones",
            tooltip = "Click to spawn clone"
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

script.on_event(defines.events.on_gui_click,
        function(event)
    if event.element and event.element.name == "kagebunshins_spawn" then
        onButtonClick(game.players[1])
    end
end)

