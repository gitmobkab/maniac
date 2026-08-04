package shaders

import "core:math"
import "../models"

MANDELBROT_MAX_ITER :: 40
MANDELBROT_CHARS := [10]rune{' ', '.', ':', '-', '=', '+', '*', '#', '%', '@'}

shader_mandelbrot :: proc(input: models.Shading_Input) -> models.Cell {
    aspect := input.resolution.x / (input.resolution.y * 2.0) // rows are ~2x taller than columns
    nx := (input.frag_coord.x / input.resolution.x - 0.5) * 2.0 * aspect
    ny := (input.frag_coord.y / input.resolution.y - 0.5) * 2.0

    // Slow zoom that breathes in and out, centered on a point on the boundary
    zoom := 0.5 + 0.5 * math.sin(input.time * 0.15)
    scale := math.pow(2.5, -zoom*3.0 - 0.3)
    center_x, center_y := -0.745, 0.113

    cx := center_x + nx * scale
    cy := center_y + ny * scale

    zx, zy := 0.0, 0.0
    iter := 0
    for iter < MANDELBROT_MAX_ITER {
        zx2, zy2 := zx*zx, zy*zy
        if zx2 + zy2 > 4.0 {
            break
        }
        zy = 2.0*zx*zy + cy
        zx = zx2 - zy2 + cx
        iter += 1
    }

    if iter == MANDELBROT_MAX_ITER {
        return models.Cell{bg = models.RGB{0, 0, 0}, char = ' '}
    }

    t := f64(iter) / f64(MANDELBROT_MAX_ITER)
    red   := clamp_u8((math.sin(t*math.PI*4 + 0) + 1) * 0.5 * 255)
    green := clamp_u8((math.sin(t*math.PI*4 + 2) + 1) * 0.5 * 255)
    blue  := clamp_u8((math.sin(t*math.PI*4 + 4) + 1) * 0.5 * 255)
    char_idx := clamp(int(t * f64(len(MANDELBROT_CHARS))), 0, len(MANDELBROT_CHARS)-1)

    return models.Cell{
        bg = models.RGB{0, 0, 0},
        fg = models.RGB{red, green, blue},
        char = MANDELBROT_CHARS[char_idx],
    }
}
