package shaders

import "core:math"
import "../models"

TORUS_MAJOR :: 1.0
TORUS_MINOR :: 0.4
TORUS_MARCH_STEPS :: 80
TORUS_MARCH_DIST :: 12.0
TORUS_SURF_EPS :: 0.001

sd_torus :: proc(p: models.Vec3) -> f64 {
    qx := math.sqrt(p.x*p.x + p.z*p.z) - TORUS_MAJOR
    return math.sqrt(qx*qx + p.y*p.y) - TORUS_MINOR
}

// Tumbles the sample point through two axes before evaluating the SDF, so the
// torus itself spins rather than the camera orbiting a static shape.
torus_scene :: proc(p: models.Vec3, t: f64) -> f64 {
    xz := rotate2(models.Vec2{x = p.x, y = p.z}, t * 0.7)
    q := models.Vec3{x = xz.x, y = p.y, z = xz.y}
    yz := rotate2(models.Vec2{x = q.y, y = q.z}, t * 0.5)
    q = models.Vec3{x = q.x, y = yz.x, z = yz.y}
    return sd_torus(q)
}

shader_torus :: proc(input: models.Shading_Input) -> models.Cell {
    t := input.time

    ro, rd, ux, uy := camera_ray(input, 3.2, 1.6)
    d, hit, steps := raymarch(ro, rd, t, torus_scene, TORUS_MARCH_STEPS, TORUS_MARCH_DIST, TORUS_SURF_EPS)

    if !hit {
        // Soft radial vignette for the void behind the torus
        vign := clamp(1.0 - length2(models.Vec2{x = ux, y = uy}) * 0.35, 0, 1)
        shade := u8(clamp(vign * 22, 0, 255))
        return models.Cell{bg = models.RGB{shade, shade, u8(clamp(vign * 34, 0, 255))}, char = ' '}
    }

    p := models.Vec3{x = ro.x + rd.x*d, y = ro.y + rd.y*d, z = ro.z + rd.z*d}
    n := calc_normal(p, t, torus_scene)

    light := normalize3(models.Vec3{x = -0.5, y = 0.7, z = -0.8})
    view := models.Vec3{x = -rd.x, y = -rd.y, z = -rd.z}
    half := normalize3(models.Vec3{x = light.x + view.x, y = light.y + view.y, z = light.z + view.z})

    diff := max(dot3(n, light), 0.0)
    spec := math.pow(max(dot3(n, half), 0.0), 32.0)
    rim := math.pow(1.0 - max(dot3(n, view), 0.0), 3.0)
    ao := 1.0 - f64(steps) / f64(TORUS_MARCH_STEPS) * 0.5 // cheap fake AO from step count

    // Slowly cycling hue so the surface catches shifting color as it turns
    hue := t * 0.3
    base_r := (math.sin(hue) + 1.0) * 0.5
    base_g := (math.sin(hue + 2.09) + 1.0) * 0.5
    base_b := (math.sin(hue + 4.18) + 1.0) * 0.5

    lit := diff * 0.8 + 0.15
    r := base_r*lit*ao + spec + rim*0.3
    g := base_g*lit*ao + spec + rim*0.3
    b := base_b*lit*ao + spec + rim*0.4

    return models.Cell{
        bg = models.RGB{
            u8(clamp(r * 255, 0, 255)),
            u8(clamp(g * 255, 0, 255)),
            u8(clamp(b * 255, 0, 255)),
        },
        char = ' ',
    }
}
