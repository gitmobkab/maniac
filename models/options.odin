package models

Options :: struct {
    version: bool `usage:"Show the project version and exit"`,
    headless: bool `usage:"Remove header and footer from the screen. (hence headless mode)."`,
    fps: i32 `usage:"The target fps (Frame Per Second) to use. x <= 0 to go uncapped (i think). Default: 60"`,
    shut_up: bool `usage:"Keep rendering normally even when the terminal loses focus."`,
}

