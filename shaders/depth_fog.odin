package shaders

import "core:math"

import "../models"

shader_depth_fog :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x / input.resolution.x
    y := input.frag_coord.y / input.resolution.y

    // Fake "depth" via a rippling sine field standing in for a scene
    depth := (math.sin(x*10 + input.time) + math.sin(y*10 - input.time*0.7)) * 0.5 + 0.5

    fog := u8(clamp(depth * 100, 0, 255)) // background dims with distance
    surface := u8(clamp((1.0 - depth) * 255, 0, 255)) // foreground brightens when near

    return models.Cell{
        bg_r = 0, bg_g = 0, bg_b = fog,
        fg_r = surface, fg_g = surface, fg_b = surface,
        char = '#',
    }
}