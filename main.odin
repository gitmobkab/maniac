package main

import "core:time"

import "terminal"
import "game_loop"

DEFAULT_ROWS :: 35
DEFAUTL_COLUMNS :: 80

main :: proc() {
    terminal.install_sigint_handler()
    terminal.install_resize_handler()

    terminal.init_raw_mode()
    defer terminal.restore_cooked_mode()
    terminal.start_alt_mode()
    defer terminal.stop_alt_mode()

    term := &terminal.global_term
    term.rows = DEFAULT_ROWS
    term.columns = DEFAUTL_COLUMNS
    terminal.update_window_size()
    start_time := time.now()
    
    target_fps := 60
    target_frame_time := time.Duration(f64(time.Second) / f64(target_fps))

    for !terminal.global_term.should_quit {
        frame_start := time.now()
        elapsed := time.duration_seconds(time.since(start_time))

        game_loop.render_frame(term.rows, term.columns, elapsed)

        frame_elapsed := time.since(frame_start)
        remaining := target_frame_time - frame_elapsed
        if remaining > 0 {
            time.accurate_sleep(remaining)
        }
    }
}
