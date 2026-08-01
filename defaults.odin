package main

import "models"

DEFAULT_FPS :: 60
DEFAULT_WIDTH :: 800
DEFAULT_HEIGHT :: 450

DefaultOptions :: proc() -> models.Options {
    return models.Options{
        fps = DEFAULT_FPS,
    }
} 