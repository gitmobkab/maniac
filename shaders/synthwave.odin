package shaders

import "core:math"
import "../models"

SYNTHWAVE_SUN_COLOR := [3]f64{255, 140, 60}
SYNTHWAVE_SKY_TOP := [3]f64{20, 10, 40}
SYNTHWAVE_SKY_BOTTOM := [3]f64{255, 90, 140}
SYNTHWAVE_GRID_COLOR := [3]f64{255, 30, 200}

shader_synthwave :: proc(input: models.Shading_Input) -> models.Cell {
    horizon := input.resolution.y * 0.55
    x := input.frag_coord.x
    y := input.frag_coord.y

    if y < horizon {
        // Sky: vertical gradient plus a sun disc sitting on the horizon
        t := clamp(y / horizon, 0, 1)
        r := mix(SYNTHWAVE_SKY_TOP[0], SYNTHWAVE_SKY_BOTTOM[0], t)
        g := mix(SYNTHWAVE_SKY_TOP[1], SYNTHWAVE_SKY_BOTTOM[1], t)
        b := mix(SYNTHWAVE_SKY_TOP[2], SYNTHWAVE_SKY_BOTTOM[2], t)

        sun_cx := input.resolution.x / 2.0
        sun_radius := input.resolution.x * 0.12
        dx := x - sun_cx
        dy := (y - horizon) * 2.0 // aspect correction
        dist := math.sqrt(dx*dx + dy*dy)

        // Horizontal scanline bands cut across the lower half of the sun disc
        in_sun := dist < sun_radius
        scanline := int(math.floor((horizon - y) * 0.8)) % 3 == 0
        in_lower_half := y > horizon - sun_radius*0.5
        if in_sun && (!in_lower_half || !scanline) {
            return models.Cell{
                bg_r = u8(clamp(SYNTHWAVE_SUN_COLOR[0], 0, 255)),
                bg_g = u8(clamp(SYNTHWAVE_SUN_COLOR[1], 0, 255)),
                bg_b = u8(clamp(SYNTHWAVE_SUN_COLOR[2], 0, 255)),
                char = ' ',
            }
        }

        return models.Cell{
            bg_r = u8(clamp(r, 0, 255)),
            bg_g = u8(clamp(g, 0, 255)),
            bg_b = u8(clamp(b, 0, 255)),
            char = ' ',
        }
    }

    // Ground: perspective grid receding toward the horizon, scrolling toward the viewer
    ground_y := y - horizon + 1.0
    depth := input.resolution.y / ground_y // grows as the grid approaches the camera

    cx := input.resolution.x / 2.0
    perspective_x := (x - cx) * depth * 0.05 + cx

    scroll := input.time * 8.0
    line_z := glsl_mod(depth + scroll, 4.0)
    is_horizontal_line := line_z < 0.3

    lane_width := 6.0
    line_width := 0.3 + depth * 0.05
    is_vertical_line := glsl_mod(perspective_x, lane_width) < line_width

    fade := clamp(1.0 - ground_y/(input.resolution.y*0.6), 0, 1)

    if is_horizontal_line || is_vertical_line {
        return models.Cell{
            bg_r = 10, bg_g = 5, bg_b = 20,
            fg_r = u8(clamp(SYNTHWAVE_GRID_COLOR[0]*fade, 0, 255)),
            fg_g = u8(clamp(SYNTHWAVE_GRID_COLOR[1]*fade, 0, 255)),
            fg_b = u8(clamp(SYNTHWAVE_GRID_COLOR[2]*fade, 0, 255)),
            char = '-',
        }
    }

    return models.Cell{bg_r = 10, bg_g = 5, bg_b = 20, char = ' '}
}
