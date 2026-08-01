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

/*
    Handle complex (stupid) parsing logic for terminal keys 

    obscure: handle windows resize event
*/
poll_key :: proc() -> (Key_Event, bool) // stub, not a type