package terminal

Key :: enum u8 {
    None,
    Char,
    Arrow_Up, 
    Arrow_Down, 
    Arrow_Left, 
    Arrow_Right,
}

Focus :: enum u8 {
    In,
    Out,
}

Event_Kind :: enum u8 {
    Key,
    Focus,
}

Event :: struct {
    kind:  Event_Kind,
    key:   Key,    // valid when kind == .Key
    char:  rune,   // valid when kind == .Key && key == .Char
    focus: Focus,  // valid when kind == .Focus
}