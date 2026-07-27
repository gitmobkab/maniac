package terminal

import "core:terminal/ansi"
import "core:strconv"
import "core:strings"


import "../models"

draw_cell :: proc(builder: ^strings.Builder, cell: models.Cell) {
    buf: [8]u8
    draw_cell_color(builder, cell, buf[:], false)
    draw_cell_color(builder, cell, buf[:], true)

    strings.write_rune(builder, cell.char)

    strings.write_string(builder, ansi.CSI)
    strings.write_string(builder, ansi.RESET)
    strings.write_string(builder, ansi.SGR)

}

draw_cell_color :: proc(builder: ^strings.Builder, cell: models.Cell, buf: []byte, is_background: bool = false) {
    strings.write_string(builder, ansi.CSI)
    color_bit := ansi.BG_COLOR_24_BIT if is_background else ansi.FG_COLOR_24_BIT
    strings.write_string(builder, color_bit)
    
    strings.write_byte(builder, ';')

    red := cell.bg_r if is_background else cell.fg_r
    r_str := strconv.write_int(buf[:], i64(red), 10)
    strings.write_string(builder, r_str)

    strings.write_byte(builder, ';')

    green := cell.bg_g if is_background else cell.fg_g
    g_str := strconv.write_int(buf[:], i64(green), 10)
    strings.write_string(builder, g_str)
    
    strings.write_byte(builder, ';')

    blue := cell.bg_b if is_background else cell.fg_b
    b_str := strconv.write_int(buf[:], i64(blue), 10)
    strings.write_string(builder, b_str)

    strings.write_string(builder, ansi.SGR)
}
