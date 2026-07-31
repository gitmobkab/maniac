package terminal

import "core:terminal/ansi"
import "core:strings"

import "../shaders"

Command :: struct {
    key: rune,
    help: string
}

COMMANDS := [?]Command{
    {'q', "quit"},
    {'←', "previous shader"},
    {'→', "next shader"},
    {'f', "Toggle headless mode"}
}
ERASE_FULL_LINE :: ansi.CSI + "2" + ansi.EL
HEADER_BOTTOM_CHAR :: "▁"
FOOTER_TOP_CHAR :: "▔"
FOOTER_PADDING :: 5
ELAPSED_LABEL :: "Elapsed Time: "

elapsed_time_buf: [32]byte

draw_header :: proc(builder: ^strings.Builder, height, shader_id: int) {
    shader := shaders.SHADERS[shader_id]
    target_row := get_target_row(height)
    width := global_term.columns
    target_column := ceil_div(width, 2) - (len(shader.name) / 2) // ignore pls
    for row in 0..=height {
        move_cursor_to(builder, row)
        strings.write_string(builder, ERASE_FULL_LINE)

        set_bg_color_to(builder, 41, 41, 41)
        
        if row == target_row {
            move_cursor_to(builder, row, target_column)
            strings.write_string(builder, shader.name)
            strings.write_string(builder, " [")
            strings.write_int(builder, shader_id+1)
            strings.write_string(builder, "/")
            strings.write_int(builder, len(shaders.SHADERS))
            strings.write_string(builder, "]")
        } else if row == height{
            set_fg_color_to(builder, 255, 255, 255)
            strings.write_string(builder, strings.repeat(HEADER_BOTTOM_CHAR, width))
        }
    }
    reset_all(builder)
}

draw_footer :: proc(builder: ^strings.Builder, height: int, elapsed_time: f64) {
    row_start := global_term.rows - height + 1
    row_end := global_term.rows
    target_row := row_start + height / 2
    width := global_term.columns
    for row in row_start..=row_end {
        move_cursor_to(builder, row)
        strings.write_string(builder, ERASE_FULL_LINE)

        set_bg_color_to(builder, 41, 42, 45)
        set_fg_color_to(builder, 255, 255, 255)

        if row == row_start {
            strings.write_string(builder, strings.repeat(FOOTER_TOP_CHAR, width))
        } else if row == target_row {
            move_cursor_to(builder, row, FOOTER_PADDING)
            write_commands(builder)
            
            strings.write_string(builder, ELAPSED_LABEL)
            strings.write_f64(builder, elapsed_time, 'g')
        }
    }
}

write_commands :: proc(builder: ^strings.Builder) {
    for command in COMMANDS {
        set_fg_color_to(builder, 164, 184 , 242)
        strings.write_rune(builder, command.key)
        set_fg_color_to(builder, 255, 255, 255)
        strings.write_string(builder, " ")
        strings.write_string(builder, command.help)
        strings.write_string(builder, "\t")
    }
}

get_target_row :: proc(height: int) -> int {
    return ceil_div(height, 2)
}

ceil_div :: proc(a, b: int) -> int {
    return (a + b - 1) / b
}

/*
    When i started my CS degree on a new first freshman year.
    My eyes were filled with joy and excitment.
    I strived to make amazing, beautiful and impressive softwares.
    Because i liked the idea of building things.
    Now...
    I just wish i'd taken another carrier.

    I'm never going to make a tui with this level of barebone either.
*/