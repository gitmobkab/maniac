package shaders

import "core:math"
import "../models"

shader_ripple :: proc(input: models.Shading_Input) -> models.Cell {
    cx := input.resolution.x / 2.0
    cy := input.resolution.y / 2.0
    dx := input.frag_coord.x - cx
    dy := (input.frag_coord.y - cy) * 2.0 // aspect correction

    dist := math.sqrt(dx*dx + dy*dy)
    wave := math.sin(dist * 0.5 - input.time * 3.0)

    brightness := (wave + 1.0) * 0.5
    intensity := u8(clamp(brightness * 255, 0, 255))

    return models.Cell{
        bg_r = 0,
        bg_g = intensity,
        bg_b = u8(clamp(f64(255 - int(intensity)), 0, 255)),
        char = ' '}
}