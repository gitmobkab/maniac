package terminal

import "core:terminal/ansi"
import "core:strconv"
import "core:strings"


import "../models"

draw_cell :: proc(builder: ^strings.Builder, cell: models.Cell) {
    draw_cell_color(builder, cell, false)
    draw_cell_color(builder, cell, true)

    strings.write_rune(builder, cell.char)

    reset_all(builder)
}

draw_cell_color :: proc(builder: ^strings.Builder, cell: models.Cell, is_background: bool = false) {
    if is_background {
        set_bg_color_to(builder, cell.bg)
    } else {
        set_fg_color_to(builder, cell.fg)
    }
}
