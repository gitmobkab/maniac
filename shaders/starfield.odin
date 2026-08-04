package shaders

import "core:math"
import "../models"

STAR_DENSITY :: 0.06

shader_starfield :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x
    y := input.frag_coord.y

    // Discretize into a fixed grid so each star's position is stable frame to frame
    cell_x := math.floor(x)
    cell_y := math.floor(y)

    seed := hash(cell_x, cell_y)
    if seed > STAR_DENSITY {
        return models.Cell{bg = models.RGB{0, 0, 0}, char = ' '}
    }

    // Twinkle: brightness oscillates per-star at its own phase/speed
    phase := hash(cell_x + 1, cell_y + 1) * math.PI * 2
    speed := 1.0 + hash(cell_x, cell_y + 2) * 3.0
    twinkle := (math.sin(input.time * speed + phase) + 1.0) * 0.5

    brightness := u8(clamp(140 + twinkle * 115, 0, 255))
    chars := [3]rune{'.', '*', '+'}
    char_idx := clamp(int(seed / STAR_DENSITY * 3), 0, 2)

    return models.Cell{
        bg = models.RGB{0, 0, 0},
        fg = models.RGB{brightness, brightness, brightness},
        char = chars[char_idx],
    }
}
