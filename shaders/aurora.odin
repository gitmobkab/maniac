package shaders

import "core:math"
import "../models"

AURORA_BASE := [3]f64{5, 8, 20} // deep night sky, curtains glow on top of this

shader_aurora :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x
    y := input.frag_coord.y
    height_frac := y / input.resolution.y // 0 = top of sky, 1 = horizon

    // Several vertically-drifting curtains of light at different heights and speeds
    band := 0.0
    band += value_noise(x * 0.05 + input.time * 0.3, height_frac * 2.0) * 0.6
    band += value_noise(x * 0.11 - input.time * 0.5 + 40, height_frac * 3.0 + 10) * 0.4
    band += value_noise(x * 0.03 + input.time * 0.15 + 90, height_frac * 1.5 + 20) * 0.3

    // Curtains glow strongest in the upper sky and fade out near the ground
    curtain := clamp(band - height_frac * 0.8, 0, 1)
    curtain = curtain * curtain

    hue := 2.0 + band * 1.5 // drifts between green and violet
    red   := AURORA_BASE[0] + (math.sin(hue) * 0.5 + 0.5) * curtain * 200
    green := AURORA_BASE[1] + (math.sin(hue + 2.0) * 0.5 + 0.5) * curtain * 255
    blue  := AURORA_BASE[2] + (math.sin(hue + 4.0) * 0.5 + 0.5) * curtain * 220

    return models.Cell{
        bg = models.RGB{ 
            clamp_u8(red),
            clamp_u8(green),
            clamp_u8(blue),
        },
        char = ' ',
    }
}
