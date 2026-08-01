package models

Options :: struct {
    version: bool `usage:"Show the project version and exit"`,
    headless: bool `usage:"Run in headless mode."`,
    fps: i32 `usage:"The target fps (Frame Per Second) to use. Negative to go uncapped. Default: 60"`,
}

