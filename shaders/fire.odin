package shaders

import "core:math"
import "../models"

FIRE_CHARS := [5]rune{' ', '.', ':', '^', '#'}

shader_fire :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x * 0.15
    y := input.frag_coord.y * 0.15 - input.time * 3.5 // scroll upward over time

    // Layered noise (turbulence) for a rougher, more organic flame texture
    n := value_noise(x, y)
    n += value_noise(x * 2.3, y * 2.3) * 0.5
    n += value_noise(x * 5.1, y * 5.1) * 0.25
    n /= 1.75

    // Per-column wobble so neighboring flames don't breathe in sync
    flicker := math.sin(input.frag_coord.x * 0.7 + input.time * 6.0) * 0.08

    // Fade toward the top of the screen, tapering faster than a linear falloff
    height_frac := input.frag_coord.y / input.resolution.y
    fade := clamp(1.0 - height_frac, 0, 1)
    fade = fade * fade

    intensity := clamp((n + flicker) * fade * 1.6, 0, 1)

    // Color ramp: black -> red -> orange -> yellow -> white as intensity rises
    r := clamp_u8(intensity * 3.0 * 255)
    g := clamp_u8((intensity - 0.33) * 3.0 * 255)
    b := clamp_u8((intensity - 0.75) * 4.0 * 255)

    char_idx := clamp(int(intensity * f64(len(FIRE_CHARS))), 0, len(FIRE_CHARS) - 1)

    return models.Cell{
        bg = models.RGB{r, g, b},
        fg = models.RGB{255, 255, 200},
        char = FIRE_CHARS[char_idx],
    }
}
