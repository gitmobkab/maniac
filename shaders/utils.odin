package shaders

import "core:math"

import "../models"

shader_proc :: proc(input: models.Shading_Input) -> models.Cell

SHADERS := [?]shader_proc{
    shader_creation,
    shader_depth_fog,
    shader_fire,
    shader_gradient,
    shader_matrix,
    shader_NaN,
    shader_plasma,
    shader_ripple,
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
