package gameloop

import "core:strings"
import "core:os"
import "core:time"

import "../terminal"
import "../shaders"

DEFAULT_ROWS :: 35
DEFAUTL_COLUMNS :: 80
HEADER_HEIGHT :: 3
FOOTER_HEIGHT :: 3
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
    global_builder := strings.builder_make()
    defer strings.builder_destroy(&global_builder)

    render_params := RenderParams{
        row_start = HEADER_HEIGHT + 1,
        builder = &global_builder,
    }
    for !term.should_quit {
        strings.builder_reset(&global_builder)
        key_buf: [1]u8
        n, _ := os.read(os.stdin, key_buf[:])

        if n > 0 {
            key := key_buf[0]
            switch key {
            case 'q', 'Q':
                term.should_quit = true
            case 0x1b:
                seq_buf: [2]u8
                esc_n, _ := os.read(os.stdin, seq_buf[:])
                if esc_n == 2 && seq_buf[0] == '[' {
                    arrow_key := seq_buf[1]
                    switch arrow_key {
                    case 'C':
                        current_shader += 1
                    case 'D':
                        current_shader -= 1
                    }
                    // need refactoring (obviously)
                }
            }
            
        }
        frame_start := time.now()
        elapsed := time.duration_seconds(time.since(start_time))

        render_params.row_end = term.rows - FOOTER_HEIGHT - 1
        render_params.column_end = term.columns + 1

        current_shader = wrap_index(current_shader, shaders_num)

        terminal.draw_header(&global_builder, HEADER_HEIGHT, current_shader)
        render_frame(render_params, elapsed, current_shader)
        terminal.draw_footer(&global_builder, FOOTER_HEIGHT, elapsed)

        frame_elapsed := time.since(frame_start)
        remaining := target_frame_time - frame_elapsed
        if remaining > 0 {
            time.accurate_sleep(remaining)
        }
        os.write_string(os.stdout, strings.to_string(global_builder))
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