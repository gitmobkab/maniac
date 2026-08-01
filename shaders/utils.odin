package shaders

import "core:math"

import "../models"

shader_proc :: #type proc(input: models.Shading_Input) -> models.Cell

Shader :: struct {
    name: string,
    s_proc: shader_proc
}

SHADERS := [?]Shader{
    {"balatro", shader_balatro},
    {"creation", shader_creation},
    {"depth fog", shader_depth_fog},
    {"fire", shader_fire},
    {"gradient", shader_gradient},
    {"matrix", shader_matrix},
    {"<Missing texture>", shader_NaN},
    {"plasma", shader_plasma},
    {"ripple the waves", shader_ripple},
    {"starfield", shader_starfield},
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