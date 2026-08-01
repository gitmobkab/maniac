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


get_stdin_handle :: proc() -> win.HANDLE  {
    return win.GetStdHandle(win.STD_INPUT_HANDLE)
}


get_stdout_handle :: proc() -> win.HANDLE  {
    return win.GetStdHandle(win.STD_OUTPUT_HANDLE)
}

init_raw_mode :: proc() {
    stdin_h := get_stdin_handle()
    cooked_mode: win.DWORD
    win.GetConsoleMode(stdin_h, &cooked_mode)
    for mode in RAW_MODE_DWORDS {
        cooked_mode &~= mode
    }
    cooked_mode |= win.ENABLE_WINDOW_INPUT
    win.SetConsoleMode(stdin_h, cooked_mode)

    stdout_h := get_stdout_handle()
    out_mode: win.DWORD
    win.GetConsoleMode(stdout_h, &out_mode)
    win.SetConsoleMode(stdout_h, out_mode | win.ENABLE_VIRTUAL_TERMINAL_PROCESSING)
}


restore_cooked_mode :: proc() {
    stdin_h := get_stdin_handle()
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


update_window_size :: proc() {
    stdout_h := win.GetStdHandle(win.STD_OUTPUT_HANDLE)
    info: win.CONSOLE_SCREEN_BUFFER_INFO
    if win.GetConsoleScreenBufferInfo(stdout_h, &info) {
        global_term.columns = int(info.srWindow.Right - info.srWindow.Left + 1)
        global_term.rows = int(info.srWindow.Bottom - info.srWindow.Top + 1)
    }
}

/*
    Handle complex (stupid) parsing logic for terminal keys 

    obscure: handle windows resize event
*/
poll_key :: proc() -> (Key_Event, bool) {
    stdin_h := get_stdin_handle()

    for {
        number_of_events: win.DWORD
        win.GetNumberOfConsoleInputEvents(stdin_h, &number_of_events)
        if number_of_events == 0 {
            return Key_Event{}, false
        }

        record: win.INPUT_RECORD
        events_read: win.DWORD
        win.ReadConsoleInputW(stdin_h, &record, 1, &events_read)

        #partial switch record.EventType {
        case .WINDOW_BUFFER_SIZE_EVENT:
            size := record.Event.WindowBufferSizeEvent.dwSize
            global_term.columns = int(size.X)
            global_term.rows = int(size.Y)
            // no key to report yet, loop again for the next queued event

        case .KEY_EVENT:
            key_event := record.Event.KeyEvent
            if !bool(key_event.bKeyDown) {
                continue // ignore key-up, loop again
            }
            switch key_event.wVirtualKeyCode {
            case win.VK_LEFT:
                return Key_Event{key = .Arrow_Left}, true
            case win.VK_RIGHT:
                return Key_Event{key = .Arrow_Right}, true
            case win.VK_UP:
                return Key_Event{key = .Arrow_Up}, true
            case win.VK_DOWN:
                return Key_Event{key = .Arrow_Down}, true
            case:
                return Key_Event{key = .Char, char = rune(key_event.uChar.UnicodeChar)}, true
            }

        case:
            // MOUSE_EVENT / MENU_EVENT / FOCUS_EVENT — not interesting, loop again
        }
    }
}
