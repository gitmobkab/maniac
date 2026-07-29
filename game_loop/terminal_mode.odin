package gameloop

import "core:math"
import "core:os"
import "core:time"

import "../terminal"
import "../shaders"

DEFAULT_ROWS :: 35
DEFAUTL_COLUMNS :: 80
shaders_num := len(shaders.SHADERS)

terminal_mode :: proc(){

    terminal.init()
    defer terminal.cleanup()

    term := &terminal.global_term
    term.rows = DEFAULT_ROWS
    term.columns = DEFAUTL_COLUMNS
    terminal.update_window_size()
    start_time := time.now()
    
    target_fps := 60
    target_frame_time := time.Duration(f64(time.Second) / f64(target_fps))

    current_shader := 0
    for !term.should_quit {
        key_buf: [1]u8
        n, _ := os.read(os.stdin, key_buf[:])

        if n > 0 {
            key := key_buf[0]
            switch key {
            case 'q':
                term.should_quit = true
            case 'd': 
                current_shader += 1
            case 'a':
                current_shader -= 1
            case :
                // i secretly hate femboys.
            }
            
        }
        frame_start := time.now()
        elapsed := time.duration_seconds(time.since(start_time))

        current_shader = wrap_index(current_shader, shaders_num)
        render_frame(term.rows, term.columns, elapsed, current_shader)

        frame_elapsed := time.since(frame_start)
        remaining := target_frame_time - frame_elapsed
        if remaining > 0 {
            time.accurate_sleep(remaining)
        }
    }
}

/*
    Wanted to use the x %= limit trick but Odin modulo follows C style
    Which the prevent the wraping to actually do it's job once the index goes negative.
    and core:math.wrap only works on floats
    so i add to make mine, pulled the formula from CS degree
    please update if odin got a proper procedure for that
*/
wrap_index :: proc(index, count: int) -> int {
    return (index % count + count) % count
}