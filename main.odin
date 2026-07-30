package main

import "core:os"
import "core:flags"

import "game_loop"

Options :: struct {
    gpu: bool `usage:"Enable to use GPU based shaders instead."`
}

main :: proc() {
    opt: Options
    flags.parse_or_exit(&opt, os.args, .Unix)
    if opt.gpu {
        game_loop.gui()
    } else {
        game_loop.terminal_mode()
    }
}