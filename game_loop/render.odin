package gameloop

import "core:strings"
import "core:os"

import "../shaders"
import "../models"
import "../terminal"

render_frame :: proc(params: RenderParams, elapsed_time: f64, shader_id: int) {
    builder := strings.builder_make()
    defer strings.builder_destroy(&builder)

    
    resolution := models.Vec2{
        f64(params.column_end - params.column_start),
        f64(params.row_end - params.row_start)
    }


    for row in params.row_start..=params.row_end {
        for column in params.column_start..=params.column_end {
            input := models.Shading_Input{
                resolution = resolution,
                time = elapsed_time,
                frag_coord = models.Vec2{
                    f64(column - params.column_start), 
                    f64(row - params.row_start)
                },
            }

            current_shader := shaders.SHADERS[shader_id]
            cell := current_shader(input)

            
            terminal.move_cursor_to(&builder, row, column)

            // Set background color and write the character
            terminal.draw_cell(&builder, cell)
    }
}

    frame_string := strings.to_string(builder)
    os.write(os.stdout, transmute([]byte)frame_string)
}

RenderParams :: struct{
    row_start, row_end : int,
    column_start, column_end : int
}