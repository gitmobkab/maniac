package shaders

import "core:math"
import "../models"

VORONOI_SCALE :: 0.15

shader_voronoi :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x * VORONOI_SCALE
    y := input.frag_coord.y * 2.0 * VORONOI_SCALE + input.time * 0.3 // aspect correction: rows are ~2x taller than columns

    ix, iy := math.floor(x), math.floor(y)

    min_dist := 8.0
    for oy in -1..=1 {
        for ox in -1..=1 {
            cell_x := ix + f64(ox)
            cell_y := iy + f64(oy)

            // Random feature point inside this cell
            px := cell_x + hash(cell_x, cell_y)
            py := cell_y + hash(cell_y, cell_x)

            dx := px - x
            dy := py - y
            d := math.sqrt(dx*dx + dy*dy)
            min_dist = min(min_dist, d)
        }
    }

    brightness := clamp(1.0 - min_dist, 0, 1)
    hue := hash(ix, iy) * math.PI * 2

    red   := u8(clamp((math.sin(hue) + 1) * 127 * brightness, 0, 255))
    green := u8(clamp((math.sin(hue + 2.0) + 1) * 127 * brightness, 0, 255))
    blue  := u8(clamp((math.sin(hue + 4.0) + 1) * 127 * brightness, 0, 255))

    return models.Cell{
        bg = models.RGB{red, green, blue},
        char = ' ',
    }
}
