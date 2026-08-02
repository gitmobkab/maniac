package shaders

import "core:math"

import "../models"

shader_proc :: #type proc(input: models.Shading_Input) -> models.Cell

Shader :: struct {
    name: string,
    s_proc: shader_proc
}

SHADERS := [?]Shader{
    {"aurora", shader_aurora},
    {"balatro", shader_balatro},
    {"blob", shader_blob},
    {"creation", shader_creation},
    {"cube", shader_cube},
    {"depth fog", shader_depth_fog},
    {"dna helix", shader_dna},
    {"fire", shader_fire},
    {"glitch", shader_glitch},
    {"gradient", shader_gradient},
    {"kaleidoscope", shader_kaleidoscope},
    {"mandelbrot", shader_mandelbrot},
    {"matrix", shader_matrix},
    {"metaballs", shader_metaballs},
    {"<Missing texture>", shader_NaN},
    {"plasma", shader_plasma},
    {"rain", shader_rain},
    {"ripple the waves", shader_ripple},
    {"starfield", shader_starfield},
    {"synthwave", shader_synthwave},
    {"torus", shader_torus},
    {"tunnel", shader_tunnel},
    {"voronoi", shader_voronoi},
}

value_noise :: proc(x, y: f64) -> f64 {
    ix, iy := math.floor(x), math.floor(y)
    fx, fy := x - ix, y - iy

    a := hash(ix, iy)
    b := hash(ix + 1, iy)
    c := hash(ix, iy + 1)
    d := hash(ix + 1, iy + 1)

    top := a + (b - a) * fx
    bottom := c + (d - c) * fx
    return top + (bottom - top) * fy
}

hash :: proc(x, y: f64) -> f64 {
    n := math.sin(x * 12.9898 + y * 78.233) * 43758.5453
    return n - math.floor(n)
}

// GLSL's mod() is floored modulo, different from Odin's %/math.mod (truncated).
// mod(x, y) = x - y * floor(x/y)
glsl_mod :: proc(x, y: f64) -> f64 {
    return x - y * math.floor(x / y)
}


// Linear interpolation between a and b by t (GLSL: mix)
mix :: proc(a, b, t: f64) -> f64 {
    return a*(1.0-t) + b*t
}

// GLSL: step(edge, x) -> 0.0 if x < edge, else 1.0
step :: proc(edge, x: f64) -> f64 {
    return 1.0 if x >= edge else 0.0
}

// Length of a 2D vector
length2 :: proc(v: models.Vec2) -> f64 {
    return math.sqrt(v.x*v.x + v.y*v.y)
}

// Length of a 3D vector
length3 :: proc(v: models.Vec3) -> f64 {
    return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
}

// Dot product of two 3D vectors
dot3 :: proc(a, b: models.Vec3) -> f64 {
    return a.x*b.x + a.y*b.y + a.z*b.z
}

// Unit-length version of a 3D vector
normalize3 :: proc(v: models.Vec3) -> models.Vec3 {
    l := length3(v)
    return models.Vec3{x = v.x/l, y = v.y/l, z = v.z/l}
}

// Smooth minimum, blends two SDF shapes together (used in raymarching)
smin :: proc(a, b, k: f64) -> f64 {
    h := clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0)
    return mix(b, a, h) - k*h*(1.0-h)
}

// Rotate a 2D vector by angle a (GLSL: mat2 rotation)
rotate2 :: proc(p: models.Vec2, a: f64) -> models.Vec2 {
    c := math.cos(a)
    s := math.sin(a)
    return models.Vec2{x = c*p.x - s*p.y, y = s*p.x + c*p.y}
}

// A time-varying signed distance function, as used by the raymarched 3D shaders
Sdf_Proc :: #type proc(p: models.Vec3, t: f64) -> f64

// Aspect-correct camera ray for a cell: ro is the eye, rd the view direction.
// ux/uy are also returned since callers use them for background vignettes.
camera_ray :: proc(input: models.Shading_Input, cam_dist, focal: f64) -> (ro, rd: models.Vec3, ux, uy: f64) {
    res := input.resolution
    scale := min(res.x, res.y * 2.0) * 0.5
    ux = (input.frag_coord.x - res.x/2.0) / scale
    uy = (input.frag_coord.y - res.y/2.0) * 2.0 / scale

    ro = models.Vec3{x = 0, y = 0, z = -cam_dist}
    rd = normalize3(models.Vec3{x = ux, y = -uy, z = focal})
    return
}

// Sphere-traces along rd from ro until the scene SDF is nearly zero (hit) or
// the ray has gone too far (miss). Returns the travelled distance, whether it
// hit, and how many steps it took (used for cheap fake ambient occlusion).
raymarch :: proc(ro, rd: models.Vec3, t: f64, scene: Sdf_Proc, max_steps: int, max_dist, surf_eps: f64) -> (dist: f64, hit: bool, steps: int) {
    for i in 0..<max_steps {
        p := models.Vec3{x = ro.x + rd.x*dist, y = ro.y + rd.y*dist, z = ro.z + rd.z*dist}
        s := scene(p, t)
        dist += s
        steps = i
        if s < surf_eps {
            hit = true
            break
        }
        if dist > max_dist {
            break
        }
    }
    return
}

// Surface normal via central-difference gradient of the SDF (standard raymarching trick)
calc_normal :: proc(p: models.Vec3, t: f64, scene: Sdf_Proc) -> models.Vec3 {
    e := 0.0015
    dx := scene(models.Vec3{x = p.x+e, y = p.y, z = p.z}, t) - scene(models.Vec3{x = p.x-e, y = p.y, z = p.z}, t)
    dy := scene(models.Vec3{x = p.x, y = p.y+e, z = p.z}, t) - scene(models.Vec3{x = p.x, y = p.y-e, z = p.z}, t)
    dz := scene(models.Vec3{x = p.x, y = p.y, z = p.z+e}, t) - scene(models.Vec3{x = p.x, y = p.y, z = p.z-e}, t)
    return normalize3(models.Vec3{x = dx, y = dy, z = dz})
}