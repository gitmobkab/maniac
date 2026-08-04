package terminal

import "core:terminal/ansi"
import "core:strconv"
import "core:strings"

import "../shaders"
import "../models"

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
FOOTER_GAP :: 2 // minimum blank columns between the command legend and the elapsed-time stat
FOOTER_TRUNC_INDICATOR :: "…"
FOOTER_TAB_WIDTH :: 8 // conservative estimate, tabs don't have a fixed visible width
ELAPSED_LABEL :: "Elapsed Time: "


elapsed_time_buf: [32]byte

draw_header :: proc(builder: ^strings.Builder, height, shader_id: int) {
    shader := shaders.SHADERS[shader_id]
    target_row := get_target_row(height)
    width := global_term.columns

    id_buf, count_buf: [8]u8
    id_str := strconv.write_int(id_buf[:], i64(shader_id+1), 10)
    count_str := strconv.write_int(count_buf[:], i64(len(shaders.SHADERS)), 10)

    // full visible label is "<name> [<id>/<count>]", not just the name
    label_width := len(shader.name) + len(" [") + len(id_str) + len("/") + len(count_str) + len("]")
    target_column := (width - label_width) / 2 + 1

    if height == 0 {
        return
    }
    // as couter intuitive as it looks based on the wikipedia article
    // it really seems that terminals grid start at 0 on x in most kitty and ghostty
    for row in 0..=height {
        move_cursor_to(builder, row)
        strings.write_string(builder, ERASE_FULL_LINE)

        set_bg_color_to(builder, HEADER_FOOTER_BG)

        if row == target_row {
            move_cursor_to(builder, row, target_column)
            strings.write_string(builder, shader.name)
            strings.write_string(builder, " [")
            strings.write_string(builder, id_str)
            strings.write_string(builder, "/")
            strings.write_string(builder, count_str)
            strings.write_string(builder, "]")
        } else if row == height{
            set_fg_color_to(builder, GENERIC_WHITE)
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

    elapsed_buf: [32]u8
    elapsed_str := strconv.write_float(elapsed_buf[:], elapsed_time, 'f', 2, 64)
    if len(elapsed_str) > 1 && elapsed_str[0] == '+' && elapsed_str[1] != 'I' {
        elapsed_str = elapsed_str[1:]
    }
    suffix_width := len(ELAPSED_LABEL) + len(elapsed_str)
    elapsed_column := width - FOOTER_PADDING - suffix_width + 1

    for row in row_start..=row_end {
        move_cursor_to(builder, row)
        strings.write_string(builder, ERASE_FULL_LINE)

        set_bg_color_to(builder, HEADER_FOOTER_BG)
        set_fg_color_to(builder, GENERIC_WHITE)

        if row == row_start {
            strings.write_string(builder, strings.repeat(FOOTER_TOP_CHAR, width))
        } else if row == target_row {
            move_cursor_to(builder, row, FOOTER_PADDING)
            write_commands(builder, elapsed_column - FOOTER_GAP - FOOTER_PADDING)

            move_cursor_to(builder, row, elapsed_column)
            strings.write_string(builder, ELAPSED_LABEL)
            strings.write_string(builder, elapsed_str)
        }
    }
}

write_commands :: proc(builder: ^strings.Builder, max_width: int) {
    used := 0
    for command, i in COMMANDS {
        entry_width := 1 + 1 + len(command.help) + FOOTER_TAB_WIDTH // key + space + help + tab
        is_last := i == len(COMMANDS) - 1
        reserve := 0 if is_last else len(FOOTER_TRUNC_INDICATOR)

        if used + entry_width + reserve > max_width {
            set_fg_color_to(builder, BLUEISH)
            strings.write_string(builder, FOOTER_TRUNC_INDICATOR)
            return
        }

        set_fg_color_to(builder, BLUEISH)
        strings.write_rune(builder, command.key)
        set_fg_color_to(builder, GENERIC_WHITE)
        strings.write_string(builder, " ")
        strings.write_string(builder, command.help)
        strings.write_string(builder, "\t")
        used += entry_width
    }
}

// fills the entire terminal with a flat dim color, used while unfocused
draw_dim_screen :: proc(builder: ^strings.Builder) {
    width := global_term.columns
    for row in 1..=global_term.rows {
        move_cursor_to(builder, row)
        strings.write_string(builder, ERASE_FULL_LINE)
        set_bg_color_to(builder, DIM_BG)
        strings.write_string(builder, strings.repeat(" ", width))
    }
    reset_all(builder)
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
