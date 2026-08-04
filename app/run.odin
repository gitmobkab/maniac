package app

import "core:strings"
import "core:os"
import "core:time"
import "core:unicode"

import "../terminal"
import "../shaders"
import "../models"

DEFAULT_HEADER_HEIGHT :: 3
DEFAULT_FOOTER_HEIGHT :: 3
shaders_num := len(shaders.SHADERS)

run :: proc(opts: ^models.Options) {
    
    terminal.init()
    defer terminal.cleanup()
    
    term := &terminal.global_term
    start_time := time.now()
    
    target_fps := opts.fps
    target_frame_time := time.Duration(f64(time.Second) / f64(target_fps))
    
    current_shader := 0
    update_title_to_shader(current_shader)
    global_builder := strings.builder_make()
    defer strings.builder_destroy(&global_builder)

    render_params := RenderParams{
        builder = &global_builder,
    }
    header_height, footer_height : int
    for !term.should_quit {
        strings.builder_reset(&global_builder)
        event, ok := terminal.poll_event()

        if ok {
            switch event.kind {
            case .Key:
                switch event.key {
                case .Char:
                    switch unicode.to_lower(event.char) {
                    case 'q':
                        term.should_quit = true
                    case 'f':
                        opts.headless = !opts.headless
                    }
                case .Arrow_Right:
                    current_shader += 1
                    current_shader = wrap_index(current_shader, shaders_num)
                    update_title_to_shader(current_shader)
                case .Arrow_Left:
                    current_shader -= 1
                    current_shader = wrap_index(current_shader, shaders_num)
                    update_title_to_shader(current_shader)
                case .Arrow_Up, .Arrow_Down, .None:
                    // unused
                }
            case .Focus:
                was_focused := term.focused
                term.focused = event.focus == .In
                if was_focused && !term.focused {
                    terminal.draw_dim_screen(&global_builder)
                    os.write_string(os.stdout, strings.to_string(global_builder))
                }
            }
        }
        frame_start := time.now()
        elapsed := time.duration_seconds(time.since(start_time))

        if term.focused {
            current_shader = wrap_index(current_shader, shaders_num)

            if opts.headless {
                header_height = 0
                footer_height = 0
            } else {
                header_height = DEFAULT_HEADER_HEIGHT
                footer_height = DEFAULT_FOOTER_HEIGHT
            }
            render_params.row_start = header_height + 1
            render_params.row_end = term.rows - footer_height
            render_params.column_end = term.columns

            terminal.draw_header(&global_builder, header_height, current_shader)
            terminal.draw_footer(&global_builder, footer_height, elapsed)
            render_frame(render_params, elapsed, current_shader)
        }

        frame_elapsed := time.since(frame_start)
        remaining := target_frame_time - frame_elapsed
        if remaining > 0 {
            time.accurate_sleep(remaining)
        }
        if term.focused {
            os.write_string(os.stdout, strings.to_string(global_builder))
        }
    }
}