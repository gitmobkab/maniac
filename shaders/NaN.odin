package shaders

import "core:math"
import "../models"


shader_NaN :: proc(input: models.Shading_Input) -> models.Cell {
    SQUARE_SIZE :: 2.0 // terminal cells per checker square

    // Aspect-correct so squares look square-ish, not stretched
    aspect := input.resolution.y / input.resolution.x * 2.0
    x := input.frag_coord.x
    y := input.frag_coord.y / aspect

    checker_x := int(math.floor(x / SQUARE_SIZE))
    checker_y := int(math.floor(y / SQUARE_SIZE))

    is_purple := (checker_x + checker_y) % 2 == 0

    if is_purple {
        return models.Cell{bg_r = 255, bg_g = 0, bg_b = 255, char = ' '} // magenta, classic "missing texture" purple
    } else {
        return models.Cell{bg_r = 0, bg_g = 0, bg_b = 0, char = ' '} // black
    }
}