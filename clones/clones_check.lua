function is_character_moved(character)
    if not kagebunshins_cords[character] then
        kagebunshins_cords[character] = {
            old_x = character.position.x,
            old_y = character.position.y
        }
        return true
    end

    local cords = kagebunshins_cords[character]

    if not (cords.x or cords.y) then
        cords.x = character.position.x
        cords.y = character.position.y
        return true
    end
    is_moved = not (cords.old_x == cords.x and cords.old_y == cords.y)
    cords.old_x = cords.x
    cords.old_y = cords.y
    cords.x = character.position.x
    cords.y = character.position.y
    return is_moved
end
