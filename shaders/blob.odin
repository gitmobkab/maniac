package shaders

import "core:math"
import "../models"

BLOB_COUNT :: 4
BLOB_BLEND :: 0.5
BLOB_MARCH_STEPS :: 80
BLOB_MARCH_DIST :: 12.0
BLOB_SURF_EPS :: 0.001

// Several spheres drifting through 3D space and smoothly merged, so the whole
// mass ripples and separates like liquid metal rather than rotating rigidly.
blob_scene :: proc(p: models.Vec3, t: f64) -> f64 {
    field := 999.0
    for i in 0..<BLOB_COUNT {
        fi := f64(i)
        center := models.Vec3{
            x = math.sin(t * 0.6 + fi * 2.1) * 0.6,
            y = math.cos(t * 0.5 + fi * 1.7) * 0.5,
            z = math.sin(t * 0.4 + fi * 3.3) * 0.6,
        }
        radius := 0.45 + 0.08 * math.sin(t * 1.3 + fi)

        d := models.Vec3{x = p.x - center.x, y = p.y - center.y, z = p.z - center.z}
        dist := length3(d) - radius
        field = smin(field, dist, BLOB_BLEND)
    }
    return field
}

shader_blob :: proc(input: models.Shading_Input) -> models.Cell {
    t := input.time

    ro, rd, ux, uy := camera_ray(input, 3.4, 1.7)
    d, hit, steps := raymarch(ro, rd, t, blob_scene, BLOB_MARCH_STEPS, BLOB_MARCH_DIST, BLOB_SURF_EPS)

    if !hit {
        vign := clamp(1.0 - length2(models.Vec2{x = ux, y = uy}) * 0.35, 0, 1)
        shade := u8(clamp(vign * 14, 0, 255))
        return models.Cell{
            bg = models.RGB{
                u8(clamp(vign * 20, 0, 255)), 
                shade,
                u8(clamp(vign * 28, 0, 255))
            },
            char = ' '
        }
    }

    p := models.Vec3{x = ro.x + rd.x*d, y = ro.y + rd.y*d, z = ro.z + rd.z*d}
    n := calc_normal(p, t, blob_scene)

    light := normalize3(models.Vec3{x = -0.4, y = 0.8, z = -0.6})
    view := models.Vec3{x = -rd.x, y = -rd.y, z = -rd.z}
    half := normalize3(models.Vec3{x = light.x + view.x, y = light.y + view.y, z = light.z + view.z})

    diff := max(dot3(n, light), 0.0)
    spec := math.pow(max(dot3(n, half), 0.0), 64.0)
    rim := math.pow(1.0 - max(dot3(n, view), 0.0), 2.5) // glassy fresnel edge glow
    ao := 1.0 - f64(steps) / f64(BLOB_MARCH_STEPS) * 0.5

    // Cool iridescent palette derived from the normal, unlike torus's global time-hue
    hue := n.x*1.5 + n.y*1.5 + t * 0.4
    base_r := (math.sin(hue) + 1.0) * 0.5
    base_g := (math.sin(hue + 2.09) + 1.0) * 0.5
    base_b := (math.sin(hue + 4.18) + 1.0) * 0.5

    lit := diff*0.7 + 0.2
    r := base_r*lit*ao + spec + rim*0.4
    g := base_g*lit*ao + spec + rim*0.5
    b := base_b*lit*ao + spec + rim*0.6

    return models.Cell{
        bg = models.RGB{
            u8(clamp(r * 255, 0, 255)),
            u8(clamp(g * 255, 0, 255)),
            u8(clamp(b * 255, 0, 255))
        },
        char = ' ',
    }
}
