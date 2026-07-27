package shaders

import "core:math"
import "../models"

shader_plasma :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x
    y := input.frag_coord.y
    t := input.time

    // Layer several sine waves moving at different speeds/directions
    v1 := math.sin(x * 0.2 + t)
    v2 := math.sin(y * 0.2 + t * 0.7)
    v3 := math.sin((x + y) * 0.15 + t * 1.3)
    v4 := math.sin(math.sqrt(x*x + y*y) * 0.2 - t)

    v := (v1 + v2 + v3 + v4) / 4.0 // combine, keep roughly in [-1, 1]

    // Map [-1, 1] to [0, 255] per channel, phase-shifted so colors separate
    red   := u8(clamp((math.sin(v * math.PI) + 1) * 127.5, 0, 255))
    green := u8(clamp((math.sin(v * math.PI + 2.0) + 1) * 127.5, 0, 255))
    blue  := u8(clamp((math.sin(v * math.PI + 4.0) + 1) * 127.5, 0, 255))

    return models.Cell{
        bg_r = red,
        bg_g = green,
        bg_b = blue,
        char = ' ',
    }
}
