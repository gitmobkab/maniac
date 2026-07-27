package main

import "core:fmt"
import "ainsi"

ROWS :: 20
COLUMNS :: 40
GREEN :: 0

main :: proc() {
    for row in 0..<ROWS {
        for column in 0..<COLUMNS {
            red_deg := f64(column) / f64(COLUMNS)
            blue_deg := f64(row) / f64(ROWS)
            red := int(red_deg * 255)
            blue := int(blue_deg * 255)
            fmt.printf("%s ", ainsi.get_background(red, blue, GREEN))
        }
        fmt.println()
    }
}