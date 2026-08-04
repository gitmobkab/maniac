package shaders

import "core:math"
import "../models"

GLITCH_CHARS := [6]rune{' ', '.', ':', '#', '%', '@'}

shader_glitch :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x
    y := math.floor(input.frag_coord.y)

    // Glitch bursts arrive in short bands that change identity every few ticks
    burst_seed := math.floor(input.time * 6.0)
    row_glitch := hash(y, burst_seed)
    is_glitch_row := row_glitch > 0.85

    shift := 0.0
    if is_glitch_row {
        shift = (hash(y, burst_seed + 1) - 0.5) * 20.0 // horizontal tear
    }
    sx := x + shift

    // Base scanline pattern with a slow vertical scroll
    scan := math.sin(y * 0.6 - input.time * 4.0)
    base := (scan + 1.0) * 0.5

    // Blocky static, coarser than per-cell so it reads as "blocks" not fine grain
    block_x := math.floor(sx / 2.0)
    block_y := y
    static_n := hash(block_x + burst_seed * 3.7, block_y)

    intensity := base * 0.3 + static_n * 0.7
    if is_glitch_row {
        intensity = static_n // pure noise where the signal is corrupted
    }

    // RGB channel split: sample each channel's "noise" at a slightly different offset
    red   := u8(clamp(hash(block_x + 1 + burst_seed*3.7, block_y) * 255 * intensity, 0, 255))
    green := u8(clamp(hash(block_x + burst_seed*3.7, block_y) * 255 * intensity, 0, 255))
    blue  := u8(clamp(hash(block_x - 1 + burst_seed*3.7, block_y) * 255 * intensity, 0, 255))

    char_idx := clamp(int(intensity * f64(len(GLITCH_CHARS))), 0, len(GLITCH_CHARS)-1)

    return models.Cell{
        bg = models.RGB{0, 0, 0},
        fg = models.RGB{red, green, blue},
        char = GLITCH_CHARS[char_idx],
    }
}
