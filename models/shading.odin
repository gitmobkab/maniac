package models

Shading_Input :: struct {
    // Uniforms — same for every cell, computed once per frame
    resolution: Vec2,   // width/height of the grid
    time:       f64,    // seconds elapsed since start

    // Varying — different per cell, this is "fragCoord" in Shadertoy terms
    frag_coord: Vec2,   // this cell's (column, row) position
}