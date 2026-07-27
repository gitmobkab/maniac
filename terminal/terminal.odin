package terminal

import "core:sys/posix"
import "core:terminal/ansi"
import "core:strconv"
import "core:strings"
import "core:os"

CLEAR_SEQ :: ansi.CSI + "2" + ansi.ED
START_ALT_MODE_SEQ := ansi.CSI + "?1049h"
STOP_ALT_MODE_SEQ := ansi.CSI + "?1049l"

should_quit: bool = false


sigint_handler :: proc "c" (sig: posix.Signal) {
    should_quit = true
}

install_sigint_handler :: proc() {
    action: posix.sigaction_t
    action.sa_handler = sigint_handler
    posix.sigaction(.SIGINT, &action, nil)
}

/*
    tell the terminal to use the alternate screen buffer.
    should be combined with defer stop_alt_mode()
*/
start_alt_mode :: proc() {
    os.write(os.stdout, transmute([]byte)START_ALT_MODE_SEQ)
}

/*
    tell the terminal to stop the alternate screnn buffer.
    see start_alt_mode()
*/
stop_alt_mode ::proc() {
    os.write(os.stdout, transmute([]byte)STOP_ALT_MODE_SEQ)
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