package shaders

import "core:math"

import "../models"


// --- SHADER CONFIG ---
SPIN_ROTATION :: -2.0
SPIN_SPEED    :: 7.0
CONTRAST      :: 3.5
LIGHTING      :: 0.4
SPIN_AMOUNT   :: 0.25
PIXEL_FILTER  :: 745.0
SPIN_EASE     :: 1.0


/*
    Balatro is owned by localthunk (https://www.playbalatro.com)

    Port from https://www.shadertoy.com/view/XXtBRr
*/
shader_balatro :: proc(input: models.Shading_Input) -> models.Cell {

    COLOUR_1 := models.Vec3{0.871, 0.267, 0.231}
    COLOUR_2 := models.Vec3{0.0, 0.42, 0.706}
    COLOUR_3 := models.Vec3{0.086, 0.137, 0.145}

    screen_len := length2(input.resolution)
    pixel_size := screen_len / PIXEL_FILTER

    px := math.floor(input.frag_coord.x * (1.0/pixel_size)) * pixel_size
    py := math.floor(input.frag_coord.y * (1.0/pixel_size)) * pixel_size

    uv := models.Vec2{
        x = (px - 0.5*input.resolution.x) / screen_len,
        y = (py - 0.5*input.resolution.y) * 2.0 / screen_len, // aspect correction: terminal rows are ~2x taller than columns
    }
    uv_len := length2(uv)

    speed := (SPIN_ROTATION*SPIN_EASE*0.2) + 302.2
    new_angle := math.atan2(uv.y, uv.x) + speed - SPIN_EASE*20.0*(SPIN_AMOUNT*uv_len + (1.0-SPIN_AMOUNT))

    mid_x := (input.resolution.x/screen_len) / 2.0
    mid_y := (input.resolution.y/screen_len) / 2.0

    uv.x = (uv_len*math.cos(new_angle) + mid_x) - mid_x
    uv.y = (uv_len*math.sin(new_angle) + mid_y) - mid_y

    uv.x *= 30.0
    uv.y *= 30.0
    speed = input.time * SPIN_SPEED

    uv2 := models.Vec2{x = uv.x + uv.y, y = uv.x + uv.y}

    for i in 0..<5 {
        m := max(uv.x, uv.y)
        uv2.x += math.sin(m)
        uv2.y += math.sin(m)
        uv.x += 0.5 * math.cos(5.1123314 + 0.353*uv2.y + speed*0.131121)
        uv.y += 0.5 * math.sin(uv2.x - 0.113*speed)
        uv.x -= math.cos(uv.x + uv.y)
        uv.y -= math.sin(uv.x*0.711 - uv.y)
    }

    contrast_mod := 0.25*CONTRAST + 0.5*SPIN_AMOUNT + 1.2
    final_len := length2(uv)
    paint_res := min(2.0, max(0.0, final_len*0.035*contrast_mod))
    c1p := max(0.0, 1.0 - contrast_mod*math.abs(1.0-paint_res))
    c2p := max(0.0, 1.0 - contrast_mod*math.abs(paint_res))
    c3p := 1.0 - min(1.0, c1p+c2p)
    light := (LIGHTING-0.2)*max(c1p*5.0-4.0, 0.0) + LIGHTING*max(c2p*5.0-4.0, 0.0)

    base := 0.3/CONTRAST
    rem := 1.0 - base

    r := base*COLOUR_1.x + rem*(COLOUR_1.x*c1p + COLOUR_2.x*c2p + c3p*COLOUR_3.x) + light
    g := base*COLOUR_1.y + rem*(COLOUR_1.y*c1p + COLOUR_2.y*c2p + c3p*COLOUR_3.y) + light
    b := base*COLOUR_1.z + rem*(COLOUR_1.z*c1p + COLOUR_2.z*c2p + c3p*COLOUR_3.z) + light

    return models.Cell{
        bg = models.RGB{
            clamp_u8(r*255),
            clamp_u8(g*255),
            clamp_u8(b*255)
        },
        char = ' ',
    }
}