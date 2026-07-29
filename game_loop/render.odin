package gameloop

import "core:strings"
import "core:os"

import "../shaders"
import "../models"
import "../terminal"

render_frame :: proc(rows, columns: int, elapsed_time: f64, shader_id: int) {
    builder := strings.builder_make()
    defer strings.builder_destroy(&builder)

    
    resolution := models.Vec2{f64(columns), f64(rows)}


    for row in 0..<rows {
        for column in 0..<columns {
            input := models.Shading_Input{
                resolution = resolution,
                time       = elapsed_time,
                frag_coord = models.Vec2{f64(column), f64(row)},
            }

            current_shader := shaders.SHADERS[shader_id]
            cell := current_shader(input)

            // Position cursor for this cell (1-indexed, terminals start at 1,1)
            terminal.move_cursor_to(&builder, row + 1, column + 1)

            // Set background color and write the character
            terminal.draw_cell(&builder, cell)
    }
}

    frame_string := strings.to_string(builder)
    os.write(os.stdout, transmute([]byte)frame_string)
}
