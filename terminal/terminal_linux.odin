package terminal

import "core:sys/posix"
import "core:sys/linux"

// interface required by linux; does not advice any module to use it
Winsize :: struct {
    ws_row: u16,
    ws_col: u16,
    ws_xpixel: u16, // unused
    ws_ypixel: u16 // unused
}



C_LFLAGS :: bit_set[posix.CLocal_Flag_Bits; posix.tcflag_t]{
    .ECHO,
    .ICANON
}

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
    original: posix.termios
    posix.tcgetattr(posix.STDIN_FILENO, &original)
    
    original.c_lflag -= C_LFLAGS
    original.c_cc[.VMIN] = 0
    original.c_cc[.VTIME] = 0
    posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &original)
    check: posix.termios
}


/*
    Restore the terminal cooked mode
*/
restore_cooked_mode :: proc() {
    raw: posix.termios
    posix.tcgetattr(posix.STDIN_FILENO, &raw)

    raw.c_lflag += C_LFLAGS
    posix.tcsetattr(posix.STDIN_FILENO, .TCSANOW, &raw)
}



/*
    update the terminal window size.
    the changes will only occur if the request was successful
*/
update_window_size :: proc "c" (_: linux.Signal = linux.Signal.SIGWINCH) {
    ws: Winsize
    result := linux.ioctl(linux.Fd(posix.STDOUT_FILENO), linux.TIOCGWINSZ, uintptr(&ws))
    if result == 0 {
        global_term.rows = int(ws.ws_row)
        global_term.columns = int(ws.ws_col)
    }
}

install_resize_handler :: proc() {
    action: linux.Sig_Action
    action.handler = update_window_size
    linux.rt_sigaction(.SIGWINCH, &action, nil)
}

install_sigint_handler :: proc() {
    action: posix.sigaction_t
    action.sa_handler = sigint_handler
    posix.sigaction(.SIGINT, &action, nil)
}

sigint_handler :: proc "c" (_: posix.Signal) {
    global_term.should_quit = true
}
