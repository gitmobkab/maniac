package gameloop

import "core:fmt"

import rl "vendor:raylib"

import "../models"
import "../shaders/glsl"

CompiledShader :: struct {
    name: string,
    shader: rl.Shader,
    time_loc: i32,
    resolution_loc: i32,
    mouse_loc: i32,
}

compiled_shaders: [dynamic]CompiledShader

gui :: proc(opts: ^models.Options) {
    width := i32(opts.width)
    height := i32(opts.height)
    rl.InitWindow(width, height, "Maniac [GPU]")
    defer rl.CloseWindow()

    rl.SetTargetFPS(opts.fps)

    current_shader_id := 0

    load_builtin_shaders(&compiled_shaders)
    defer unload_shaders(&compiled_shaders)

    for !rl.WindowShouldClose() {
        current_time := f32(rl.GetTime())
        resolution := [2]f32{
            f32(rl.GetScreenWidth()),
            f32(rl.GetScreenHeight())
        }
        mouse_pos := rl.GetMousePosition()
        mouse_vec := [2]f32{mouse_pos.x, mouse_pos.y}

        if rl.IsKeyPressed(.RIGHT) {
            current_shader_id += 1
        } else if rl.IsKeyPressed(.LEFT) {
            current_shader_id -= 1
        }

        current_shader_id := wrap_index(current_shader_id, len(compiled_shaders))
        current_shader := compiled_shaders[current_shader_id]

        rl.SetShaderValue(current_shader.shader, current_shader.time_loc, &current_time, .FLOAT)
        rl.SetShaderValue(current_shader.shader, current_shader.resolution_loc, &resolution, .VEC2)
        rl.SetShaderValue(current_shader.shader, current_shader.mouse_loc, &mouse_vec, .VEC2)
        rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)

            rl.BeginShaderMode(current_shader.shader)
                rl.DrawRectangle(0, 0, width, height, rl.WHITE)
            rl.EndShaderMode()

        rl.EndDrawing()
    }

}


load_builtin_shaders :: proc(compiling_target: ^[dynamic]CompiledShader) {
    for shader in glsl.SHADERS {
        compiled_shader := rl.LoadShaderFromMemory(nil, shader.source)
        time_loc := rl.GetShaderLocation(compiled_shader, "iTime")
        resolution_loc := rl.GetShaderLocation(compiled_shader, "iResolution")
        mouse_loc := rl.GetShaderLocation(compiled_shader, "iMouse")
        append(
            &compiled_shaders,
            CompiledShader{
                shader.name, 
                compiled_shader,
                time_loc,
                resolution_loc,
                mouse_loc
            }
        )
        fmt.printfln("[MANIAC] :: Loaded built-in shader %s (%d) Chars", shader.name, len(shader.source))
    }
}

unload_shaders :: proc(compiling_target: ^[dynamic]CompiledShader) {
    for loaded_shader in compiling_target {
        rl.UnloadShader(loaded_shader.shader)
        fmt.println("[MANIAC] :: Unloaded built-in shader", loaded_shader.name)
    }
}