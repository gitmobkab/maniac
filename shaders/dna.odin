package shaders

import "core:math"
import "../models"

DNA_RADIUS :: 0.68
DNA_TUBE :: 0.18
DNA_TWIST :: 1.7
DNA_SPIN_SPEED :: 1.1
DNA_RUNG_SPACING :: 1.05
DNA_RUNG_HALF_THICK :: 0.055
DNA_MARCH_STEPS :: 140
DNA_MARCH_DIST :: 14.0
DNA_SURF_EPS :: 0.0015
// The y-dependent twist shears space (more so farther from the axis), so the
// untwisted SDF can overestimate true distance near the tube. Sphere-tracing
// with the raw value overshoots and skips past the thin tube, punching holes
// in it that shift as the helix spins. Shrinking each step keeps it safe.
DNA_STEP_FUDGE :: 0.35

// Untwists world space around the vertical axis so the helix becomes a pair
// of straight vertical rods in local space; the twist rate depends on y and
// drifts with time so the whole strand appears to spin in place.
dna_untwist :: proc(p: models.Vec3, t: f64) -> models.Vec3 {
    a := p.y * DNA_TWIST + t * DNA_SPIN_SPEED
    xz := rotate2(models.Vec2{x = p.x, y = p.z}, -a)
    return models.Vec3{x = xz.x, y = p.y, z = xz.y}
}

dna_strand_a :: proc(q: models.Vec3) -> f64 {
    dx := q.x - DNA_RADIUS
    return math.sqrt(dx*dx + q.z*q.z) - DNA_TUBE
}

dna_strand_b :: proc(q: models.Vec3) -> f64 {
    dx := q.x + DNA_RADIUS
    return math.sqrt(dx*dx + q.z*q.z) - DNA_TUBE
}

// Base-pair rungs: a thin box spanning between the two backbones, repeated
// periodically up the (untwisted, so still straight) y axis.
dna_rung :: proc(q: models.Vec3) -> f64 {
    ry := glsl_mod(q.y + DNA_RUNG_SPACING*0.5, DNA_RUNG_SPACING) - DNA_RUNG_SPACING*0.5
    rp := models.Vec3{x = q.x, y = ry, z = q.z}
    half := models.Vec3{x = DNA_RADIUS - DNA_TUBE*0.5, y = DNA_RUNG_HALF_THICK, z = DNA_RUNG_HALF_THICK}
    qx := math.abs(rp.x) - half.x
    qy := math.abs(rp.y) - half.y
    qz := math.abs(rp.z) - half.z
    outside := length3(models.Vec3{x = max(qx, 0.0), y = max(qy, 0.0), z = max(qz, 0.0)})
    inside := min(max(qx, max(qy, qz)), 0.0)
    return outside + inside
}

dna_scene :: proc(p: models.Vec3, t: f64) -> f64 {
    q := dna_untwist(p, t)
    d := min(dna_strand_a(q), dna_strand_b(q))
    d = min(d, dna_rung(q))
    return d * DNA_STEP_FUDGE
}

shader_dna :: proc(input: models.Shading_Input) -> models.Cell {
    t := input.time

    ro, rd, ux, uy := camera_ray(input, 3.6, 1.7)
    d, hit, steps := raymarch(ro, rd, t, dna_scene, DNA_MARCH_STEPS, DNA_MARCH_DIST, DNA_SURF_EPS)

    if !hit {
        // Soft radial vignette for the void behind the helix, instead of flat black
        vign := clamp(1.0 - length2(models.Vec2{x = ux, y = uy}) * 0.3, 0, 1)
        shade := clamp_u8(vign * 16)
        return models.Cell{bg = models.RGB{shade, clamp_u8(vign * 20), clamp_u8(vign * 28)}, char = ' '}
    }

    p := models.Vec3{x = ro.x + rd.x*d, y = ro.y + rd.y*d, z = ro.z + rd.z*d}
    n := calc_normal(p, t, dna_scene)
    q := dna_untwist(p, t)

    // Re-evaluate each component at the hit point to see which one we landed
    // on, so the backbones and base pairs can carry distinct colors.
    da := dna_strand_a(q)
    db := dna_strand_b(q)
    dr := dna_rung(q)

    base: models.Vec3
    if da <= db && da <= dr {
        base = models.Vec3{x = 0.25, y = 0.55, z = 1.0} // strand A backbone: blue
    } else if db <= dr {
        base = models.Vec3{x = 1.0, y = 0.3, z = 0.65} // strand B backbone: magenta
    } else {
        idx := int(math.floor((q.y + DNA_RUNG_SPACING*0.5) / DNA_RUNG_SPACING))
        if idx % 2 == 0 {
            base = models.Vec3{x = 1.0, y = 0.55, z = 0.15} // base pair: amber
        } else {
            base = models.Vec3{x = 0.35, y = 1.0, z = 0.45} // base pair: green
        }
    }

    light := normalize3(models.Vec3{x = -0.5, y = 0.7, z = -0.8})
    view := models.Vec3{x = -rd.x, y = -rd.y, z = -rd.z}
    half := normalize3(models.Vec3{x = light.x + view.x, y = light.y + view.y, z = light.z + view.z})

    diff := max(dot3(n, light), 0.0)
    spec := math.pow(max(dot3(n, half), 0.0), 40.0)
    rim := math.pow(1.0 - max(dot3(n, view), 0.0), 3.0)
    ao := 1.0 - f64(steps) / f64(DNA_MARCH_STEPS) * 0.5 // cheap fake AO from step count

    lit := diff*0.85 + 0.15
    r := base.x*lit*ao + spec + rim*0.15
    g := base.y*lit*ao + spec + rim*0.15
    b := base.z*lit*ao + spec + rim*0.2

    return models.Cell{
        bg = models.RGB{
            clamp_u8(r * 255),
            clamp_u8(g * 255),
            clamp_u8(b * 255),
        },
        char = ' ',
    }
}
