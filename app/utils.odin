package app

import "core:strings"

import "../shaders"
import "../terminal"

TITLE_PREFIX :: "maniac - "

/*
    Wanted to use the x %= limit trick but Odin modulo follows C style
    Which the prevent the wraping to actually do it's job once the index goes negative.
    and core:math.wrap only works on floats
    so i add to make mine, pulled the formula from CS degree
    please update if odin got a proper procedure for that
*/
wrap_index :: proc(index, count: int) -> int {
    return (index % count + count) % count
}

/*
    Utils 101
    Today tips, become a hater of string concatenation
*/
update_title_to_shader :: proc(shader_id: int) {
    title := strings.concatenate({TITLE_PREFIX, shaders.SHADERS[shader_id].name})
    defer delete(title)
    terminal.set_title_to(title)
}