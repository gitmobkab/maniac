package models


// a rendered cell, contains all the informations to perform drawing bullshit
Cell :: struct {
    fg, bg: RGB,
    char: rune,
}
