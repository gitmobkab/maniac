package terminal

import "core:terminal/ansi"
import "core:strconv"
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

Paused_Card_Line :: struct {
    text: string,
    is_hint: bool,
}

PAUSED_CARD_LINES := [?]Paused_Card_Line{
    {PAUSED_TITLE, false},
    {"", false},
    {PAUSED_LINE_1, false},
    {PAUSED_LINE_2, false},
    {"", false},
    {PAUSED_HINT, true},
}

PAUSED_TITLE :: "PAUSED"
PAUSED_LINE_1 :: "i'm a Maniac but you still got to"
PAUSED_LINE_2 :: "focus on me"
PAUSED_HINT :: "disable with flag '--shut-up'"
PAUSED_CARD_PADDING :: 2
BOX_TOP_LEFT :: "┌"
BOX_TOP_RIGHT :: "┐"
BOX_BOTTOM_LEFT :: "└"
BOX_BOTTOM_RIGHT :: "┘"
BOX_HORIZONTAL :: "─"
BOX_VERTICAL :: "│"
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
            write_repeated(builder, HEADER_BOTTOM_CHAR, width)
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
            write_repeated(builder, FOOTER_TOP_CHAR, width)
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


// dims the whole terminal and shows a centered "paused" card, used while unfocused
draw_dim_screen :: proc(builder: ^strings.Builder) {
    width := global_term.columns
    height := global_term.rows

    for row in 1..=height {
        move_cursor_to(builder, row)
        strings.write_string(builder, ERASE_FULL_LINE)
        set_bg_color_to(builder, DIM_BG)
        write_repeated(builder, " ", width)
    }

    content_width := 0
    for line in PAUSED_CARD_LINES {
        content_width = max(content_width, len(line.text))
    }
    inner_width := content_width + PAUSED_CARD_PADDING * 2
    box_width := inner_width + 2
    box_height := len(PAUSED_CARD_LINES) + PAUSED_CARD_PADDING * 2 + 2

    box_row := (height - box_height) / 2 + 1
    box_col := (width - box_width) / 2 + 1

    move_cursor_to(builder, box_row, box_col)
    set_bg_color_to(builder, PAUSED_CARD_BG)
    set_fg_color_to(builder, PAUSED_CARD_FG)
    strings.write_string(builder, BOX_TOP_LEFT)
    write_repeated(builder, BOX_HORIZONTAL, inner_width)
    strings.write_string(builder, BOX_TOP_RIGHT)

    row := box_row + 1
    for _ in 0..<PAUSED_CARD_PADDING {
        draw_paused_card_blank_row(builder, row, box_col, inner_width)
        row += 1
    }

    for line in PAUSED_CARD_LINES {
        move_cursor_to(builder, row, box_col)
        set_bg_color_to(builder, PAUSED_CARD_BG)
        set_fg_color_to(builder, PAUSED_CARD_FG)
        strings.write_string(builder, BOX_VERTICAL)

        left_pad := (inner_width - len(line.text)) / 2
        right_pad := inner_width - len(line.text) - left_pad
        write_repeated(builder, " ", left_pad)

        set_fg_color_to(builder, PAUSED_HINT_FG if line.is_hint else PAUSED_CARD_FG)
        strings.write_string(builder, line.text)

        set_fg_color_to(builder, PAUSED_CARD_FG)
        write_repeated(builder, " ", right_pad)
        strings.write_string(builder, BOX_VERTICAL)
        row += 1
    }

    for _ in 0..<PAUSED_CARD_PADDING {
        draw_paused_card_blank_row(builder, row, box_col, inner_width)
        row += 1
    }

    move_cursor_to(builder, row, box_col)
    set_bg_color_to(builder, PAUSED_CARD_BG)
    set_fg_color_to(builder, PAUSED_CARD_FG)
    strings.write_string(builder, BOX_BOTTOM_LEFT)
    write_repeated(builder, BOX_HORIZONTAL, inner_width)
    strings.write_string(builder, BOX_BOTTOM_RIGHT)

    reset_all(builder)
}

@(private)
draw_paused_card_blank_row :: proc(builder: ^strings.Builder, row, col, inner_width: int) {
    move_cursor_to(builder, row, col)
    set_bg_color_to(builder, PAUSED_CARD_BG)
    strings.write_string(builder, BOX_VERTICAL)
    write_repeated(builder, " ", inner_width)
    strings.write_string(builder, BOX_VERTICAL)
}

// writes s repeated count times directly into builder, avoiding the
// per-frame allocation (and leak) that strings.repeat + write_string would cause
write_repeated :: proc(builder: ^strings.Builder, s: string, count: int) {
    for _ in 0..<count {
        strings.write_string(builder, s)
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
