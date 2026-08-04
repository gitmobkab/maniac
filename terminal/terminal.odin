package terminal

import "core:terminal/ansi"
import "core:strconv"
import "core:strings"
import "core:os"

DEFAULT_ROWS :: 35
DEFAULT_COLUMNS :: 80
CLEAR_SEQ :: ansi.CSI + "2" + ansi.ED

START_ALT_MODE_SEQ :: ansi.CSI + "?1049h"
STOP_ALT_MODE_SEQ :: ansi.CSI + "?1049l"
SHOW_CURSOR_SEQ :: ansi.CSI + ansi.DECTCEM_SHOW
HIDE_CURSOR_SEQ :: ansi.CSI + ansi.DECTCEM_HIDE
OSC_WINDOW_TITLE :: ansi.OSC + ansi.WINDOW_TITLE + ";"

global_term := Terminal {
    should_quit = false,
    focused = true,
}

// rows and cols are optionals fallbacks
init :: proc(rows: int = DEFAULT_ROWS, cols: int = DEFAULT_COLUMNS) {
    install_sigint_handler()
    install_resize_handler()

    init_raw_mode()
    start_alt_mode()
    enable_focus_reporting()

    // should fix the issue on windows and other terminals
    hide_cursor()

    global_term.rows = rows
    global_term.columns = cols
    update_window_size() // try to update the terminal to it's real size
}

cleanup :: proc() {
    defer restore_cooked_mode()
    defer stop_alt_mode()
    defer show_cursor()
    defer disable_focus_reporting()
}

hide_cursor :: proc() {
    os.write_string(os.stdout, HIDE_CURSOR_SEQ)
}

show_cursor :: proc() {
    os.write_string(os.stdout, SHOW_CURSOR_SEQ)
}

// set the terminal window/tab title (OSC 2)
set_title_to :: proc(title: string) {
    os.write_string(os.stdout, OSC_WINDOW_TITLE)
    os.write_string(os.stdout, title)
    os.write_string(os.stdout, ansi.ST)
}

/*
    tell the terminal to use the alternate screen buffer.
    should be combined with defer stop_alt_mode()
*/
start_alt_mode :: proc() {
    os.write_string(os.stdout, START_ALT_MODE_SEQ)
}

/*
    tell the terminal to stop the alternate screnn buffer.
    see start_alt_mode()
*/
stop_alt_mode ::proc() {
    os.write_string(os.stdout, STOP_ALT_MODE_SEQ)
}

/*
    clear the entire screen and move the cursor at (row, col)
    just a convenience wrapper on clear_screen and move_cursor_to

    by default calling this proc without row and col will move the cursor at the upper left
*/
clear_and_move :: proc(builder: ^strings.Builder, row: int = 1, col: int = 1) {
    clear_screen(builder)
    move_cursor_to(builder, row, col)
}

// clear the screen but doesn't move the cursor
clear_screen :: proc(builder: ^strings.Builder) {
    strings.write_string(builder, CLEAR_SEQ)
}

// move the cursor to the specified (row, col) coordinates
// the values default to (1, 1), which is the upper left corner of the terminal
move_cursor_to :: proc(builder: ^strings.Builder, row: int = 1, col: int = 1) {
    buf1, buf2: [8]u8
    row_str := strconv.write_int(buf1[:], i64(row), 10)
    col_str := strconv.write_int(buf2[:], i64(col), 10)

    strings.write_string(builder, ansi.CSI)
    strings.write_string(builder, row_str)
    strings.write_byte(builder, ';')
    strings.write_string(builder, col_str)
    strings.write_string(builder, ansi.CUP)
}
// i was somehow half-asleep when reading the docs about ansi coordinates (sorry)