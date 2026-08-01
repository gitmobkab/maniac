package terminal

import "core:sys/posix"

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

