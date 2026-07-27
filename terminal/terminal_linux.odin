package terminal

import "core:sys/posix"
import "core:sys/linux"

Winsize :: struct{
    ws_row: u16,
    ws_col: u16,
    ws_xpixel: u16, // unused
    ws_ypixel: u16 // unused
}

@(private)
backup: posix.termios

/*
    Init the terminal raw mode.
    It is adviced to immediatly defer the restore_cooked_mode 
    to prevent corrupting the user terminal on any exit.
    Calling this function won't make the display use alternative screen.

    See terminal.start_alt_mode() and terminal.stop_alt_mode().

    **Examples**:
    
    package "main"

    import "../terminal"

    main :: proc() {
        init_raw_mode()
        defer restore_cooked_mode()
        // your code goes here
    }
    
*/
init_raw_mode :: proc() {
    posix.tcgetattr(posix.STDIN_FILENO, &backup)
    raw := backup
    raw.c_lflag -= {.ECHO, .ICANON}
    posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &raw)
    check: posix.termios
    if posix.tcgetattr(posix.STDIN_FILENO, &check); check != raw {
        panic("raw mode did not succeed")
    }
}

/*
    Restore the terminal cooked mode
*/
restore_cooked_mode :: proc() {
    posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &backup)
}

/*
    Return the window_size in (rows, columns)
    the last bool indicate either the operation was successful
*/
get_window_size :: proc() -> (int, int, bool) {
    ws: Winsize
    result := linux.ioctl(linux.Fd(posix.STDOUT_FILENO), linux.TIOCGWINSZ, uintptr(&ws))
    return int(ws.ws_row), int(ws.ws_col), result == 0
}