package terminal

import "core:strconv"
import "core:strings"
import "core:terminal/ansi"

// followed by r;g;b where r,g,b are in 0..=255 (red-green-blue)
CSI_BG_24_COLOR :: ansi.CSI + ansi.BG_COLOR_24_BIT + ";"

// followed by r;g;b where r,g,b are in 0..=255 (red-green-blue)
CSI_FG_24_COLOR :: ansi.CSI + ansi.FG_COLOR_24_BIT + ";"

RESET_ALL :: ansi.CSI + ansi.RESET + ansi.SGR

// set the background color for the upcoming characters
set_bg_color_to :: proc(builder: ^strings.Builder, r, g, b: u8) {
    set_color_to(builder, CSI_BG_24_COLOR, r, g, b)
}
// set the foreground color for the upcominig characters
set_fg_color_to :: proc(builder: ^strings.Builder, r, g, b: u8) {
    set_color_to(builder, CSI_FG_24_COLOR, r, g, b)
}

// reset all the styles
reset_all :: proc(builder: ^strings.Builder) {
    strings.write_string(builder, RESET_ALL)
}

@(private)
set_color_to :: proc(builder: ^strings.Builder, prefix: string, r,g,b: u8){
    buf: [3]byte
    buf_str: string
    strings.write_string(builder, prefix)
    
    buf_str = strconv.write_int(buf[:], i64(r), 10)
    strings.write_string(builder, buf_str)
    strings.write_byte(builder, ';')

    buf_str = strconv.write_int(buf[:], i64(g), 10)
    strings.write_string(builder, buf_str)
    strings.write_byte(builder, ';')

    buf_str = strconv.write_int(buf[:], i64(b), 10)
    strings.write_string(builder, buf_str)

    strings.write_string(builder, ansi.SGR)
}