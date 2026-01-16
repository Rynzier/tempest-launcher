const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

pub fn main() !void {
    std.debug.print("Starting Program\n", .{});

    //Initialization
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "Tempest Launcher");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set FPS to 60

    // Main program loop
    while (!rl.windowShouldClose()) {
        // Update

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        rl.drawText("Yippee", 190, 200, 20, .light_gray);
    }
}

pub fn updateFrame() i8 {}

pub fn drawFrame() i8 {}
