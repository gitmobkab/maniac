package terminal

Key :: enum {
    None,
    Char,
    Arrow_Up, 
    Arrow_Down, 
    Arrow_Left, 
    Arrow_Right,
}

Key_Event :: struct {
    key:  Key,
    char: rune, 
}