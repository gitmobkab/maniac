package shaders

import "core:math"
import "../models"

SKY_COLOR := [3]f64{40, 46, 66}    // dark, distant sky
FOG_COLOR := [3]f64{170, 178, 190} // pale grey-blue haze
FOG_CHARS := [4]rune{' ', '░', '▒', '▓'}

shader_depth_fog :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x
    y := input.frag_coord.y

    // y=0 is the far horizon, y=resolution.y is right in front of the camera
    depth := 1.0 - (y / input.resolution.y) // 1 = far, 0 = near

    // A few mist layers drifting sideways at different speeds/heights for parallax
    mist := 0.0
    mist += value_noise(x * 0.04 + input.time * 0.6, y * 0.08) * 0.5
    mist += value_noise(x * 0.09 - input.time * 1.1, y * 0.05 + 10) * 0.3
    mist += value_noise(x * 0.15 + input.time * 0.3, y * 0.12 + 50) * 0.2

    // Exponential falloff thickens fog fast with depth, unlike a flat linear ramp
    fog_amount := clamp(1.0 - math.exp(-depth * 2.2), 0, 1)
    fog_amount = clamp(fog_amount + mist * 0.25, 0, 1)

    r := u8(clamp(mix(SKY_COLOR[0], FOG_COLOR[0], fog_amount), 0, 255))
    g := u8(clamp(mix(SKY_COLOR[1], FOG_COLOR[1], fog_amount), 0, 255))
    b := u8(clamp(mix(SKY_COLOR[2], FOG_COLOR[2], fog_amount), 0, 255))

    // Denser mist reads as heavier glyph texture; clear sky/near ground stays blank
    density := clamp(mist + fog_amount * 0.4, 0, 1)
    char_idx := clamp(int(density * f64(len(FOG_CHARS))), 0, len(FOG_CHARS) - 1)

    fg := u8(clamp(mix(FOG_COLOR[0], 255, fog_amount * 0.3), 0, 255))

    return models.Cell{
        bg_r = r, bg_g = g, bg_b = b,
        fg_r = fg, fg_g = fg, fg_b = fg,
        char = FOG_CHARS[char_idx],
    }
}
