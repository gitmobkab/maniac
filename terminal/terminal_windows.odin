package terminal

import win "core:sys/windows"


RAW_MODE_DWORDS :: [2]win.DWORD {
    win.ENABLE_LINE_INPUT,
    win.ENABLE_ECHO_INPUT
}

init_raw_mode :: proc() {
    stdin_h := win.GetStdHandle(win.STD_INPUT_HANDLE)
    cooked_mode: win.DWORD
    win.GetConsoleMode(stdin_h, &cooked_mode)
    for mode in RAW_MODE_DWORDS {
        cooked_mode &~= mode
    }
    win.SetConsoleMode(stdin_h, cooked_mode)

    stdout_h := win.GetStdHandle(win.STD_OUTPUT_HANDLE)
    out_mode: win.DWORD
    win.GetConsoleMode(stdout_h, &out_mode)
    win.SetConsoleMode(stdout_h, out_mode | win.ENABLE_VIRTUAL_TERMINAL_PROCESSING)
}


restore_cooked_mode :: proc() {
    stdin_h := win.GetStdHandle(win.STD_INPUT_HANDLE)
    raw_mode: win.DWORD
    win.GetConsoleMode(stdin_h, &raw_mode)
    for mode in RAW_MODE_DWORDS {
        cooked_mode |= mode
    }
    win.SetConsoleMode(stdin_h, raw_mode)   
}

install_sigint_handler :: proc() {
    // stub, not implemented yet...
}

install_resize_handler :: proc() {
    // windows doesn't actually use a signal to handle window resize
}