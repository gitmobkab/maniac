package shaders

import "core:math"
import "../models"

KALEIDOSCOPE_SEGMENTS :: 8

shader_kaleidoscope :: proc(input: models.Shading_Input) -> models.Cell {
    cx := input.resolution.x / 2.0
    cy := input.resolution.y / 2.0

    p := models.Vec2{
        x = input.frag_coord.x - cx,
        y = (input.frag_coord.y - cy) * 2.0, // aspect correction
    }

    dist := length2(p)
    angle := glsl_mod(math.atan2(p.y, p.x) + math.PI * 2.0, math.PI * 2.0)

    wedge := math.PI * 2.0 / f64(KALEIDOSCOPE_SEGMENTS)
    segment := int(math.floor(angle / wedge))
    folded := glsl_mod(angle, wedge)
    if segment % 2 != 0 {
        folded = wedge - folded // mirror every other wedge for radial symmetry
    }

    // Rebuild a point from the folded angle and sample noise there
    sample := rotate2(models.Vec2{x = dist, y = 0}, folded + input.time * 0.4)
    v := value_noise(sample.x * 0.08, sample.y * 0.08 + input.time)

    red   := u8(clamp((math.sin(v * math.PI * 2.0) + 1) * 127.5, 0, 255))
    green := u8(clamp((math.sin(v * math.PI * 2.0 + 2.0) + 1) * 127.5, 0, 255))
    blue  := u8(clamp((math.sin(v * math.PI * 2.0 + 4.0) + 1) * 127.5, 0, 255))

    return models.Cell{
        bg = models.RGB{red, green, blue},
        char = ' ',
    }
}
