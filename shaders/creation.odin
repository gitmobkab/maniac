package shaders

import "core:math"

import "../models"

/* 
    Original: http://www.pouet.net/prod.php?which=57245
    Credits: Danilo Guanabara
    This is the port from shadertoy (https://www.shadertoy.com/view/XsXXDn) to Maniac equivalent

    Also ignore the comments since i'm doing a line by line analysis.
    So i can get better at porting populat Shaders to Maniac
*/
shader_creation :: proc(input: models.Shading_Input) -> models.Cell {
    t := input.time
    r := input.resolution // vec2 r = iResolution.xy

    c: [3]f64      // vec3 c;
    l: f64         // float l
    z := t         // float z = t;

    for i in 0..<3 {
        // vec2 uv, p = fragCoord.xy / r;
        p := models.Vec2{
            x = input.frag_coord.x / r.x,
            y = input.frag_coord.y / r.y,
        }
        uv := p        // uv = p;

        p.x -= 0.5     // p -= .5  (both components)
        p.y -= 0.5
        p.x *= r.x / r.y // p.x *= r.x/r.y;

        z += 0.07      // z += .07;
        l = math.sqrt(p.x*p.x + p.y*p.y) // l = length(p);

        // uv += p/l * (sin(z)+1.) * abs(sin(l*9.-z-z));
        factor := (math.sin(z) + 1.0) * math.abs(math.sin(l*9.0 - z - z))
        uv.x += (p.x / l) * factor
        uv.y += (p.y / l) * factor

        // c[i] = .01 / length(mod(uv, 1.) - .5);
        mod_x := glsl_mod(uv.x, 1.0) - 0.5
        mod_y := glsl_mod(uv.y, 1.0) - 0.5
        c[i] = 0.01 / math.sqrt(mod_x*mod_x + mod_y*mod_y)
    }

    // fragColor = vec4(c/l, t);  -- note: original divides by the LAST l from the loop
    red   := u8(clamp((c[0] / l) * 255, 0, 255))
    green := u8(clamp((c[1] / l) * 255, 0, 255))
    blue  := u8(clamp((c[2] / l) * 255, 0, 255))

    return models.Cell{
        bg_r = red,
        bg_g = green,
        bg_b = blue,
        char = ' ',
    }
}

