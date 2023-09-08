function getDirectionToNearestChunk(playerPosition, nearestChunk)
    local xDiff = nearestChunk.x * 32 - playerPosition.x
    local yDiff = nearestChunk.y * 32 - playerPosition.y

    if math.abs(xDiff) > math.abs(yDiff) then
        if xDiff > 0 then
            return defines.direction.east
        else
            return defines.direction.west
        end
    else
        if yDiff > 0 then
            return defines.direction.south
        else
            return defines.direction.north
        end
    end
end

function getNearestChunkToPlayer(playerPosition, chunksList)
    local nearestDistance
    local nearestChunk
    for _, chunk in pairs(chunksList) do
        local distance = (playerPosition.x - chunk.x * 32)^2 + (playerPosition.y - chunk.y * 32)^2

        if nearestDistance == nil or distance < nearestDistance then
            nearestDistance = distance
            nearestChunk = chunk
        end
    end

    return nearestChunk
end
