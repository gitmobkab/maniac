package shaders

import "core:math"

import "../models"

MATRIX_CHARS := [36]rune{
    '0','1','2','3','4','5','6','7','8','9',
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
}
MATRIX_TRAIL_LENGTH :: 16.0

shader_matrix :: proc(input: models.Shading_Input) -> models.Cell {
    col := int(input.frag_coord.x)
    row := input.frag_coord.y

    // Each column has its own falling offset and speed
    col_seed := hash(f64(col), 0)
    speed := 5.0 + col_seed * 10.0
    offset := col_seed * input.resolution.y

    fall_pos := math.mod(row + input.time * speed + offset, input.resolution.y)
    dist_from_head := fall_pos // 0 = head of the stream (brightest)

    // Smooth fade down the trail instead of a hard cutoff, so streams taper off
    trail := clamp(1.0 - dist_from_head / MATRIX_TRAIL_LENGTH, 0, 1)
    trail = trail * trail

    // Characters flicker on their own clock so the stream feels alive even when idle
    glyph_tick := math.floor(input.time * 6.0 + col_seed * 20.0)
    char_n := hash(f64(col), glyph_tick + math.floor(row))
    char_idx := clamp(int(char_n * f64(len(MATRIX_CHARS))), 0, len(MATRIX_CHARS)-1)
    char := MATRIX_CHARS[char_idx]

    is_head := dist_from_head < 1.0
    if is_head {
        return models.Cell{
            bg_r = 0, bg_g = 0, bg_b = 0,
            fg_r = 200, fg_g = 255, fg_b = 200,
            char = char,
        } // bright white-green head
    }

    green := u8(clamp(trail * 255, 0, 255))
    return models.Cell{
        bg_r = 0, bg_g = 0, bg_b = 0,
        fg_r = 0, fg_g = green, fg_b = 0,
        char = char,
    }
}
