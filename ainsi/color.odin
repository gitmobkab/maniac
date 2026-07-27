package ainsi

import "core:fmt"
import "core:math"

/*
yep ainsi is weird. basically those are the values to pass to the RENDER COMMAND
"\e["

    BACKGROUND = "48;2;⟨r⟩;⟨g⟩;⟨b⟩"
    FOREGROUND = "38;2;⟨r⟩;⟨g⟩;⟨b⟩"

the goal behind is to simply output 
"\e[48;2;<r>;<g>;<b>" and vice versa

see https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
*/
BACKGROUND :: "48;2;%d;%d;%d"
FOREGROUND :: "38;2;%d;%d;%d"

clamp_rgb :: proc(r, g, b: int) -> (int, int, int) {
    clamped_r := math.clamp(r, 0, 255)
    clamped_g := math.clamp(g, 0, 255)
    clamped_b := math.clamp(b, 0, 255)
    return clamped_r, clamped_g, clamped_b
}

get_foreground :: proc(r, g, b: int) -> string {
    red, green, blue := clamp_rgb(r,g,b)
    rgb_sequence := fmt.tprintf(FOREGROUND, 
        red, green, blue
    )
    return build_ainsi_command(RENDER_COMMAND, rgb_sequence)
}

get_background :: proc(r, g, b: int) -> string {
    red, green, blue := clamp_rgb(r,g,b)
    rgb_sequence := fmt.tprintf(BACKGROUND, 
        red, green, blue
    )
    return build_ainsi_command(RENDER_COMMAND, rgb_sequence)
}
