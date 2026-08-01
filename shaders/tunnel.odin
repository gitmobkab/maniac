package shaders

import "core:math"
import "../models"

shader_tunnel :: proc(input: models.Shading_Input) -> models.Cell {
    cx := input.resolution.x / 2.0
    cy := input.resolution.y / 2.0
    dx := input.frag_coord.x - cx
    dy := (input.frag_coord.y - cy) * 2.0 // aspect correction, cells are taller than wide

    dist := math.sqrt(dx*dx + dy*dy) + 0.0001
    angle := math.atan2(dy, dx)

    // Map distance to a radial "depth" that moves toward the viewer over time
    depth := glsl_mod(20.0 / dist + input.time * 4.0, 1.0)
    stripe := glsl_mod(angle / math.PI * 6.0, 1.0)

    brightness := (1.0 - depth) * step(0.5, stripe)
    intensity := u8(clamp(brightness * 255, 0, 255))

    hue_shift := angle + input.time
    red  := u8(clamp((math.sin(hue_shift) + 1) * f64(intensity) / 2, 0, 255))
    blue := u8(clamp((math.sin(hue_shift + 2.0) + 1) * f64(intensity) / 2, 0, 255))

    return models.Cell{
        bg_r = red,
        bg_g = intensity,
        bg_b = blue,
        char = ' ',
    }
}
