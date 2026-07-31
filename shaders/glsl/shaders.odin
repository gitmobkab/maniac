package glsl

balatro_code :: #load("balatro.fs", cstring)
plasma_code :: #load("plasma.fs", cstring)

Shader :: struct {
    name: string,
    source: cstring
}

SHADERS := [?]Shader{
    {"balatro", balatro_code},
    {"plasma", plasma_code}
}