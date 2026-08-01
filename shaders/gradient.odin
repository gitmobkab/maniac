package shaders

import "core:math"
import "../models"

GRADIENT_STOPS := [4][3]f64{
    {10, 10, 40},     // deep night blue
    {120, 40, 160},   // violet
    {255, 90, 60},    // warm coral
    {255, 210, 90},   // gold
}

shader_gradient :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x / input.resolution.x
    y := input.frag_coord.y / input.resolution.y

    // Diagonal position drifting slowly over time, wrapped back into [0, 1)
    pos := glsl_mod(x * 0.7 + y * 0.3 + input.time * 0.08, 1.0)

    stop_count := len(GRADIENT_STOPS)
    scaled := pos * f64(stop_count)
    i := int(scaled) % stop_count
    j := (i + 1) % stop_count
    t := scaled - math.floor(scaled)

    a := GRADIENT_STOPS[i]
    b := GRADIENT_STOPS[j]

    red   := u8(clamp(mix(a[0], b[0], t), 0, 255))
    green := u8(clamp(mix(a[1], b[1], t), 0, 255))
    blue  := u8(clamp(mix(a[2], b[2], t), 0, 255))

    return models.Cell{
        bg_r = red,
        bg_g = green,
        bg_b = blue,
        char = ' ',
    }
}
