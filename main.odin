package main

import "core:fmt"
import "core:os"
import "core:flags"

import "app"
import "models"

main :: proc() {
    opts := DefaultOptions()
    flags.parse_or_exit(&opts, os.args, .Unix)
    if opts.version {
        fmt.println("maniac", VERSION)
        os.exit(0)
    }

    app.run(&opts)
}