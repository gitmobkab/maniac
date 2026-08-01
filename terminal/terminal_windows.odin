package terminal

import win "core:sys/windows"

CONSOLE_SCREEN_BUFFER_INFO :: struct {
    dwSize: win.COORD,  
    dwCursorPosition: win.COORD,
    wAttributes: win.WORD,
    srWindow:  win.SMALL_RECT, // This is the only thing i need based on the docs
    dwMaximumWindowSize: win.COORD,
}

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
        raw_mode |= mode
    }
    win.SetConsoleMode(stdin_h, raw_mode)   
}

install_sigint_handler :: proc() {
    win.SetConsoleCtrlHandler(sigint_handler, true)
}

sigint_handler :: proc "stdcall" (_: win.DWORD) -> win.BOOL {
    global_term.should_quit = true
    return true
}

install_resize_handler :: proc() {
    // windows doesn't actually use a signal to handle window resize
}

// stub, so compiler doesn't complain, implemented only in terminal_linux
update_window_size :: proc() {
    stdout_h := win.GetStdHandle(win.STD_OUTPUT_HANDLE)
    info: win.CONSOLE_SCREEN_BUFFER_INFO
    if win.GetConsoleScreenBufferInfo(stdout_h, &info) {
        global_term.columns = int(info.srWindow.Right - info.srWindow.Left + 1)
        global_term.rows = int(info.srWindow.Bottom - info.srWindow.Top + 1)
    }
}