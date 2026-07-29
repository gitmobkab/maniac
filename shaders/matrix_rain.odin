package shaders

import "core:math"

import "../models"

shader_matrix :: proc(input: models.Shading_Input) -> models.Cell {
    col := int(input.frag_coord.x)
    row := input.frag_coord.y

    // Each column has its own falling offset and speed
    col_seed := hash(f64(col), 0)
    speed := 5.0 + col_seed * 10.0
    offset := col_seed * input.resolution.y

    fall_pos := math.mod(row + input.time * speed + offset, input.resolution.y)
    dist_from_head := fall_pos // 0 = head of the stream (brightest)

    brightness := clamp(1.0 - dist_from_head / (input.resolution.y * 0.3), 0, 1)

    green := u8(clamp(brightness * 255, 0, 255))
    is_head := dist_from_head < 1.0

    char_n := hash(f64(col), math.floor(row + input.time*2))
    char := rune('0' + int(char_n * 10))

    if is_head {
        return models.Cell {
            bg_r = 0, bg_g = 0, bg_b = 0, 
            fg_r = 200, fg_g = 255, fg_b = 200, 
            char = char
        } // bright white-green head
    }
    return models.Cell{
        bg_r = 0, bg_g = 0, bg_b = 0, 
        fg_r = 0, fg_g = green, fg_b = 0, 
        char = char
    }
}