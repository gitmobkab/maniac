package shaders

import "../models"

shader_gradient :: proc(input: models.Shading_Input) -> models.Cell {
    red_deg  := input.frag_coord.x / input.resolution.x
    blue_deg := input.frag_coord.y / input.resolution.y

    red  := u8(red_deg * 255)
    blue := u8(blue_deg * 255)

    return models.Cell{
        bg_r = red,
        bg_g = 0,
        bg_b = blue,
        char = ' ',
    }
}
