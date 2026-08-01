package main

import "core:fmt"
import "core:os"
import "core:flags"

import "game_loop"
import "models"

main :: proc() {
    opts := DefaultOptions()
    flags.parse_or_exit(&opts, os.args, .Unix)
    if opts.version {
        fmt.println("maniac", VERSION)
        os.exit(0)
    }

    if opts.gpu {
        game_loop.gui(&opts)
    } else {
        game_loop.terminal_mode(&opts)
    }
}