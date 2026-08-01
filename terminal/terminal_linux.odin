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


@(private="file")
backup: posix.termios

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
