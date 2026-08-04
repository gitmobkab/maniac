package shaders

import "core:math"
import "../models"

shader_plasma :: proc(input: models.Shading_Input) -> models.Cell {
    x := input.frag_coord.x
    y := input.frag_coord.y
    t := input.time

    // Layer several sine waves moving at different speeds/directions
    v1 := math.sin(x * 0.2 + t)
    v2 := math.sin(y * 0.2 + t * 0.7)
    v3 := math.sin((x + y) * 0.15 + t * 1.3)
    v4 := math.sin(math.sqrt(x*x + y*y) * 0.2 - t)

    v := (v1 + v2 + v3 + v4) / 4.0 // combine, keep roughly in [-1, 1]

    // Softer amplitude + mid-tone base so channels stay pastel instead of neon-saturated
    base := 90.0
    amplitude := 85.0
    red   := base + amplitude * math.sin(v * math.PI)
    green := base + amplitude * math.sin(v * math.PI + 2.0)
    blue  := base + amplitude * math.sin(v * math.PI + 4.0)

    // Pull each channel toward the shared luminance to desaturate further
    luminance := (red + green + blue) / 3.0
    desaturation := 0.25
    red   = mix(red, luminance, desaturation)
    green = mix(green, luminance, desaturation)
    blue  = mix(blue, luminance, desaturation)

    return models.Cell{
        bg = models.RGB{
            u8(clamp(red, 0, 255)),
            u8(clamp(green, 0, 255)),
            u8(clamp(blue, 0, 255)),
        },
        char = ' ',
    }
}
