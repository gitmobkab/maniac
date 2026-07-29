package gameloop

import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 450
TARGET_FPS :: 60

gui :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "i'm gonna edge you so much")
    defer rl.CloseWindow()
    rl.SetTargetFPS(TARGET_FPS)
    
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        rl.DrawText("Nevermind i don't wanna edge anymore", SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 20, rl.LIGHTGRAY)

        rl.EndDrawing()
    }

}
