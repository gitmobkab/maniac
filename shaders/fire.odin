package shaders

import "../models"


shader_fire :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x * 0.2
    y := input.frag_coord.y * 0.2 - input.time * 3.0 // scroll upward over time

    n := value_noise(x, y)
    n += value_noise(x * 2, y * 2) * 0.5
    n /= 1.5

    // Fade brightness toward top of screen (row 0) for a "flame" look
    fade := 1.0 - (input.frag_coord.y / input.resolution.y)
    brightness := clamp(n * fade * 1.5, 0, 1)

    r := u8(clamp(brightness * 255, 0, 255))
    g := u8(clamp(brightness * 120, 0, 255))
    return models.Cell{
        bg_r = r,
        bg_g = g, 
        bg_b = 0,
        char = ' '
    }
}