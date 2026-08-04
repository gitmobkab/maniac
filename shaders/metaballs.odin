package shaders

import "core:math"
import "../models"

METABALL_COUNT :: 4

shader_metaballs :: proc(input: models.Shading_Input) -> models.Cell {
    t := input.time

    // Work in raw cell-space with y doubled (aspect correction: rows are ~2x taller
    // than columns) so distances are physically uniform and blobs render as circles.
    cx := input.resolution.x / 2.0
    cy := input.resolution.y / 2.0
    px := input.frag_coord.x - cx
    py := (input.frag_coord.y - cy) * 2.0

    scale := min(input.resolution.x, input.resolution.y * 2.0)
    orbit_radius := scale * 0.3
    ball_radius := scale * 0.12
    blend := scale * 0.08

    field := 999.0
    for i in 0..<METABALL_COUNT {
        fi := f64(i)
        // Each ball drifts along its own lissajous-ish orbit
        bx := math.sin(t * 0.6 + fi * 1.7) * orbit_radius
        by := math.cos(t * 0.5 + fi * 2.3) * orbit_radius
        radius := ball_radius + 0.03 * orbit_radius * math.sin(t + fi)

        ball := models.Vec2{x = px - bx, y = py - by}
        dist := length2(ball) - radius

        field = smin(field, dist, blend) // smoothly merge overlapping blobs
    }

    // Negative distance = inside the blended blob; glow falls off near the edge
    falloff := 1.0 / (ball_radius * 0.6)
    inside := clamp(-field * falloff, 0, 1)
    glow := clamp(1.0 - math.abs(field) * falloff * 0.75, 0, 1)

    red   := clamp_u8(inside * 255)
    green := clamp_u8((inside * 0.3 + glow * 0.6) * 255)
    blue  := clamp_u8((inside * 0.6 + glow * 0.9) * 255)

    return models.Cell{
        bg = models.RGB{red, green, blue},
        char = ' ',
    }
}
