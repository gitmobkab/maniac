package shaders

import "core:math"
import "../models"

DNA_STRAND_CHAR_A :: 'O'
DNA_STRAND_CHAR_B :: 'o'
DNA_RUNG_CHAR :: '-'
DNA_AMPLITUDE :: 10.0
DNA_WAVELENGTH :: 14.0

shader_dna :: proc(input: models.Shading_Input) -> models.Cell {
    cx := input.resolution.x / 2.0
    x := input.frag_coord.x
    y := input.frag_coord.y

    phase := y / DNA_WAVELENGTH * math.PI * 2.0 + input.time * 2.0
    sa := math.sin(phase)
    sb := math.sin(phase + math.PI)

    strand_a := cx + sa * DNA_AMPLITUDE
    strand_b := cx + sb * DNA_AMPLITUDE
    front_is_a := sa > sb // which strand crosses in front this row

    dist_a := math.abs(x - strand_a)
    dist_b := math.abs(x - strand_b)

    if dist_a < 0.6 {
        glow: u8 = 255 if front_is_a else 130
        return models.Cell{
            bg_r = 0, bg_g = 0, bg_b = 0,
            fg_r = glow, fg_g = u8(f64(glow) * 0.4), fg_b = glow,
            char = DNA_STRAND_CHAR_A,
        }
    }
    if dist_b < 0.6 {
        glow: u8 = 130 if front_is_a else 255
        return models.Cell{
            bg_r = 0, bg_g = 0, bg_b = 0,
            fg_r = u8(f64(glow) * 0.4), fg_g = glow, fg_b = glow,
            char = DNA_STRAND_CHAR_B,
        }
    }

    // Rungs connecting the strands, spaced out and only drawn in the gap between them
    between := x > min(strand_a, strand_b) && x < max(strand_a, strand_b)
    rung_row := int(math.floor(y)) % 4 == 0
    if between && rung_row {
        return models.Cell{bg_r = 0, bg_g = 0, bg_b = 0, fg_r = 120, fg_g = 120, fg_b = 140, char = DNA_RUNG_CHAR}
    }

    return models.Cell{bg_r = 0, bg_g = 0, bg_b = 0, char = ' '}
}
