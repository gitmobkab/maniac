package ainsi

import "core:fmt"

// the start of the ainsi escape sequence rabbit hole
CSI :: "\e["

// basically you'll want to inject into %s the actual command value, hence building the command
RENDER_COMMAND :: CSI + "%s" + "m"

build_ainsi_command :: proc(command: string, value: string) -> string {
    return fmt.tprintf(command, value)
}