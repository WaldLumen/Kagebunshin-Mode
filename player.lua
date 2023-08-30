local distance_in_front = 1

-- calculates the position in front of the player in order to check if there are creatures from the list "entities_to_consider"
function calculate_front_position(position, direction)
    local direction_offsets = {
        [defines.direction.north] = { x = 0, y = -distance_in_front },
        [defines.direction.east] = { x = distance_in_front, y = 0 },
        [defines.direction.south] = { x = 0, y = distance_in_front },
        [defines.direction.west] = { x = -distance_in_front, y = 0 },
        [defines.direction.northeast] = { x = distance_in_front, y = -distance_in_front },
        [defines.direction.southeast] = { x = distance_in_front, y = distance_in_front },
        [defines.direction.southwest] = { x = -distance_in_front, y = distance_in_front },
        [defines.direction.northwest] = { x = -distance_in_front, y = -distance_in_front }
    }

    local offset = direction_offsets[direction]
    if offset then
        return {x = position.x + offset.x, y = position.y + offset.y}
    end
end

return {
    calculate_front_position = calculate_front_position
}
