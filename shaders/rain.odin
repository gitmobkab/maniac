package shaders

import "core:math"
import "../models"

RAIN_CHARS := [3]rune{'|', '\'', '.'}

shader_rain :: proc(input: models.Shading_Input) -> models.Cell {
    x := math.floor(input.frag_coord.x)
    y := input.frag_coord.y

    // Each column has its own droplet spacing, fall speed, and slight diagonal drift
    col_seed := hash(x, 7)
    speed := 18.0 + col_seed * 14.0
    drift := (col_seed - 0.5) * 0.6
    spacing := 4.0 + math.floor(col_seed * 5.0)

    drop_phase := glsl_mod(y - input.frag_coord.x*drift + input.time*speed, spacing)
    is_drop := drop_phase < 1.0

    if !is_drop {
        return models.Cell{bg = models.RGB{8, 10, 18}, char = ' '}
    }

    brightness := u8(clamp(140 + hash(x, math.floor(y)) * 115, 0, 255))
    char_idx := clamp(int(col_seed * f64(len(RAIN_CHARS))), 0, len(RAIN_CHARS)-1)

    return models.Cell{
        bg = models.RGB{8, 10, 18},
        fg = models.RGB{u8(f64(brightness) * 0.6), u8(f64(brightness) * 0.75), brightness},
        char = RAIN_CHARS[char_idx],
    }
}
