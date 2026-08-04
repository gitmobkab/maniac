package shaders

import "core:math"
import "../models"

CUBE_HALF :: 0.85
CUBE_MARCH_STEPS :: 80
CUBE_MARCH_DIST :: 12.0
CUBE_SURF_EPS :: 0.001

sd_box :: proc(p: models.Vec3, half: f64) -> f64 {
    qx := math.abs(p.x) - half
    qy := math.abs(p.y) - half
    qz := math.abs(p.z) - half
    outside := length3(models.Vec3{x = max(qx, 0.0), y = max(qy, 0.0), z = max(qz, 0.0)})
    inside := min(max(qx, max(qy, qz)), 0.0)
    return outside + inside
}

// Rotates world-space p into the cube's local (unrotated) space, tumbling on
// all three axes at different speeds so the spin never looks like a simple loop.
cube_to_local :: proc(p: models.Vec3, t: f64) -> models.Vec3 {
    xz := rotate2(models.Vec2{x = p.x, y = p.z}, t * 0.5)
    q := models.Vec3{x = xz.x, y = p.y, z = xz.y}
    xy := rotate2(models.Vec2{x = q.x, y = q.y}, t * 0.35)
    q = models.Vec3{x = xy.x, y = xy.y, z = q.z}
    yz := rotate2(models.Vec2{x = q.y, y = q.z}, t * 0.65)
    q = models.Vec3{x = q.x, y = yz.x, z = yz.y}
    return q
}

cube_scene :: proc(p: models.Vec3, t: f64) -> f64 {
    return sd_box(cube_to_local(p, t), CUBE_HALF)
}

// Picks a fixed color per physical face (in local space) so each face keeps
// its own color as the cube spins, like a painted die rather than a hologram.
cube_face_color :: proc(q: models.Vec3) -> models.Vec3 {
    ax, ay, az := math.abs(q.x), math.abs(q.y), math.abs(q.z)

    if ax >= ay && ax >= az {
        return models.Vec3{x = 1.0, y = 0.25, z = 0.25} if q.x > 0 else models.Vec3{x = 0.55, y = 0.05, z = 0.05}
    }
    if ay >= az {
        return models.Vec3{x = 0.3, y = 1.0, z = 0.35} if q.y > 0 else models.Vec3{x = 0.05, y = 0.5, z = 0.1}
    }
    return models.Vec3{x = 0.3, y = 0.55, z = 1.0} if q.z > 0 else models.Vec3{x = 0.05, y = 0.2, z = 0.55}
}

shader_cube :: proc(input: models.Shading_Input) -> models.Cell {
    t := input.time

    ro, rd, ux, uy := camera_ray(input, 3.4, 1.7)
    d, hit, steps := raymarch(ro, rd, t, cube_scene, CUBE_MARCH_STEPS, CUBE_MARCH_DIST, CUBE_SURF_EPS)

    if !hit {
        vign := clamp(1.0 - length2(models.Vec2{x = ux, y = uy}) * 0.35, 0, 1)
        shade := clamp_u8(vign * 18)
        return models.Cell{
            bg = models.RGB{
                    shade, shade, clamp_u8(vign * 24)
                } , 
            char = ' '
        }
    }

    p := models.Vec3{x = ro.x + rd.x*d, y = ro.y + rd.y*d, z = ro.z + rd.z*d}
    n := calc_normal(p, t, cube_scene)
    q := cube_to_local(p, t)
    face := cube_face_color(q)

    light := normalize3(models.Vec3{x = -0.5, y = 0.7, z = -0.8})
    view := models.Vec3{x = -rd.x, y = -rd.y, z = -rd.z}
    half := normalize3(models.Vec3{x = light.x + view.x, y = light.y + view.y, z = light.z + view.z})

    diff := max(dot3(n, light), 0.0)
    spec := math.pow(max(dot3(n, half), 0.0), 48.0)
    ao := 1.0 - f64(steps) / f64(CUBE_MARCH_STEPS) * 0.5

    lit := diff*0.85 + 0.15
    r := face.x*lit*ao + spec
    g := face.y*lit*ao + spec
    b := face.z*lit*ao + spec

    return models.Cell{
        bg = models.RGB{
            clamp_u8(r * 255),
            clamp_u8(g * 255),
            clamp_u8(b * 255)
        }, 
        char = ' ',
    }
}
