package gameloop

import "core:strings"
import "core:os"
import "core:time"

import "../terminal"
import "../shaders"
import "../models"

DEFAULT_HEADER_HEIGHT :: 3
DEFAULT_FOOTER_HEIGHT :: 3
shaders_num := len(shaders.SHADERS)

terminal_mode :: proc(opts: ^models.Options) {
    
    terminal.init()
    defer terminal.cleanup()
    
    term := &terminal.global_term
    start_time := time.now()
    
    target_fps := opts.fps
    target_frame_time := time.Duration(f64(time.Second) / f64(target_fps))
    

    current_shader := 0
    global_builder := strings.builder_make()
    defer strings.builder_destroy(&global_builder)

    render_params := RenderParams{
        row_start = DEFAULT_HEADER_HEIGHT + 1,
        builder = &global_builder,
    }
    for !term.should_quit {
        strings.builder_reset(&global_builder)
        key_buf: [1]byte
        n, _ := os.read(os.stdin, key_buf[:])

        if n > 0 {
            key := key_buf[0]
            switch key {
            case 'q', 'Q':
                term.should_quit = true
            case '\e':
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

        render_params.row_end = term.rows - DEFAULT_FOOTER_HEIGHT
        render_params.column_end = term.columns

        current_shader = wrap_index(current_shader, shaders_num)

        if !opts.headless {
            terminal.draw_header(&global_builder, DEFAULT_HEADER_HEIGHT, current_shader)
            terminal.draw_footer(&global_builder, DEFAULT_FOOTER_HEIGHT, elapsed)
        }
        render_frame(render_params, elapsed, current_shader)

        frame_elapsed := time.since(frame_start)
        remaining := target_frame_time - frame_elapsed
        if remaining > 0 {
            time.accurate_sleep(remaining)
        }
        os.write_string(os.stdout, strings.to_string(global_builder))
    }
}