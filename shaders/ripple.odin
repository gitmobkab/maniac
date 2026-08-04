package shaders

import "core:math"
import "../models"

RIPPLE_SOURCES :: 3
RIPPLE_CHARS := [4]rune{' ', '.', 'o', 'O'}

shader_ripple :: proc(input: models.Shading_Input) -> models.Cell {
    cx := input.resolution.x / 2.0
    cy := input.resolution.y / 2.0

    // Ripple sources placed around the center, each firing waves at its own rate
    wave_sum := 0.0
    for i in 0..<RIPPLE_SOURCES {
        fi := f64(i)
        angle := fi * (math.PI * 2.0 / f64(RIPPLE_SOURCES)) + 0.6
        radius := min(input.resolution.x, input.resolution.y*2.0) * 0.25
        sx := cx + math.cos(angle)*radius
        sy := cy + math.sin(angle)*radius*0.5

        dx := input.frag_coord.x - sx
        dy := (input.frag_coord.y - sy) * 2.0 // aspect correction
        dist := math.sqrt(dx*dx + dy*dy)

        speed := 3.0 + fi*0.4
        decay := math.exp(-dist * 0.02)
        wave_sum += math.sin(dist*0.5 - input.time*speed) * decay
    }

    brightness := clamp((wave_sum/f64(RIPPLE_SOURCES) + 1.0) * 0.5, 0, 1)

    // Color drifts slowly through the spectrum so overlapping wavefronts read as color mixing
    hue := input.time*0.3 + brightness*2.0
    red   := clamp_u8((math.sin(hue) * 0.5 + 0.5) * brightness * 255)
    green := clamp_u8((math.sin(hue + 2.0) * 0.5 + 0.5) * brightness * 255)
    blue  := clamp_u8((math.sin(hue + 4.0) * 0.5 + 0.5) * brightness * 255)

    char_idx := clamp(int(brightness * f64(len(RIPPLE_CHARS))), 0, len(RIPPLE_CHARS)-1)

    return models.Cell{
        bg = models.RGB{red, green, blue},
        fg = models.RGB{255, 255, 255},
        char = RIPPLE_CHARS[char_idx],
    }
}
