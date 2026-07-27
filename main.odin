package main

import "core:time"

import "terminal"
import "game_loop"

DEFAULT_ROWS :: 35
DEFAUTL_COLUMNS :: 80
rows: int
columns: int

main :: proc() {
    terminal.install_sigint_handler()
    
    terminal.init_raw_mode()
    defer terminal.restore_cooked_mode()
    terminal.start_alt_mode()
    defer terminal.stop_alt_mode()

    start_time := time.now()
    w_rows, w_cols, ok := terminal.get_window_size()
    if ok {
        rows = w_rows
        columns = w_cols
    } else {
        rows = DEFAULT_ROWS
        columns = DEFAUTL_COLUMNS
    }
    
    target_fps := 60
    target_frame_time := time.Duration(f64(time.Second) / f64(target_fps))

    for !terminal.should_quit {
        frame_start := time.now()
        elapsed := time.duration_seconds(time.since(start_time))

        game_loop.render_frame(rows, columns, elapsed)

        frame_elapsed := time.since(frame_start)
        remaining := target_frame_time - frame_elapsed
        if remaining > 0 {
            time.accurate_sleep(remaining)
        }
    }
}
