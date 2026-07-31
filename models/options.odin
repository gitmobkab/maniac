package models

Options :: struct {
    version: bool `usage:"Show the project version and exit"`,
    gpu: bool `usage:"Enable to use GPU based shaders instead."`,
    headless: bool `usage:"Run in headless mode."`,
    fps: i32 `usage:"The target fps (Frame Per Second) to use. Negative to go uncapped."`,
    width: u32 `usage:"The width of the window (only works with --gpu)"`,
    height: u32 `usage:"The height of the window (only works with --gpu)"`,
}

