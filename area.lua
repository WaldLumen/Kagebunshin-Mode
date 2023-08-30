function getExploredChunks(surface)
    local exploredChunks = {}

    for chunk in surface.get_chunks() do
        if surface.is_chunk_generated(chunk) then
            exploredChunks[#exploredChunks + 1] = chunk
        end
    end

    return exploredChunks
end


function findEdgeExploredChunks(surface)

    local exploredChunks = {}
    local edgeExploredChunks = {}

    for chunk in surface.get_chunks() do
        if surface.is_chunk_generated(chunk) then
            exploredChunks[chunk.x .. "," .. chunk.y] = true
        end
    end

    for chunkStr, _ in pairs(exploredChunks) do
        local x, y = chunkStr:match("(%-?%d+),(%-?%d+)")
        x, y = tonumber(x), tonumber(y)

        local isEdgeChunk = false

        for dx = -1, 1 do
            for dy = -1, 1 do
                if (dx == 0 or dy == 0) and not exploredChunks[(x + dx) .. "," .. (y + dy)] then
                    isEdgeChunk = true
                    break
                end
            end

            if isEdgeChunk then
                break
            end
        end

        if isEdgeChunk then
            edgeExploredChunks[#edgeExploredChunks + 1] = {x = x, y = y}
        end
    end

    return edgeExploredChunks
end

function getNearestChunkToPlayer(playerPosition, chunksList)
    local nearestDistance = nil
    local nearestChunk = nil

    for _, chunk in pairs(chunksList) do
        local distance = (playerPosition.x - chunk.x * 32)^2 + (playerPosition.y - chunk.y * 32)^2

        if nearestDistance == nil or distance < nearestDistance then
            nearestDistance = distance
            nearestChunk = chunk
        end
    end

    return nearestChunk
end




return {
    getExploredChunks = getExploredChunks,
    findEdgeExploredChunks = findEdgeExploredChunks,
    getNearestChunkToPlayer = getNearestChunkToPlayer
}