package models


// a rendered cell, contains all the informations to perform drawing bullshit
Cell :: struct {
    fg_r, fg_g, fg_b: u8,
    bg_r, bg_g, bg_b: u8,
    char: rune,
}
