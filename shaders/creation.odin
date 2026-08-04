package shaders

import "core:math"

import "../models"

/* 
    Original: http://www.pouet.net/prod.php?which=57245
    Credits: Danilo Guanabara
    This is the port from shadertoy (https://www.shadertoy.com/view/XsXXDn) to Maniac equivalent

    Also ignore the comments since i'm doing a line by line analysis.
    So i can get better at porting popular Shaders to Maniac
*/
shader_creation :: proc(input: models.Shading_Input) -> models.Cell {
    t := input.time
    r := input.resolution

    c: [3]f64
    l: f64
    z := t

    for i in 0..<3 {
        p := models.Vec2{
            x = input.frag_coord.x / r.x,
            y = input.frag_coord.y / r.y,
        }
        uv := p

        p.x -= 0.5
        p.y -= 0.5
        p.x *= r.x / (r.y * 2.0) // aspect correction: terminal rows are ~2x taller than columns

        z += 0.07
        l = length2(p)

        factor := (math.sin(z) + 1.0) * math.abs(math.sin(l*9.0 - z - z))
        uv.x += (p.x / l) * factor
        uv.y += (p.y / l) * factor

        wrapped := models.Vec2{
            x = glsl_mod(uv.x, 1.0) - 0.5,
            y = glsl_mod(uv.y, 1.0) - 0.5,
        }
        c[i] = 0.01 / length2(wrapped)
    }

    red   := u8(clamp((c[0] / l) * 255, 0, 255))
    green := u8(clamp((c[1] / l) * 255, 0, 255))
    blue  := u8(clamp((c[2] / l) * 255, 0, 255))

    return models.Cell{
        bg = models.RGB{
            red, green, blue
        },
        char = ' ',
    }
}

