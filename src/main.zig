const std = @import("std");
const rg = @import("raygui");
const rl = @import("raylib");

const screenHeight = 720;
const screenWidth = 600;

pub fn main() !void {
    std.debug.print("Starting Program\n", .{});

    //Initialization
    rl.initWindow(screenWidth, screenHeight, "Tempest Launcher");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set FPS to 60

    // Main program loop
    while (!rl.windowShouldClose()) {
        // Update
        try updateFrame();

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);
        try drawFrame();
    }
}

pub fn updateFrame() !void {}

pub fn drawFrame() !void {
    if (rg.button(rl.Rectangle{ .x = 0, .y = 0, .width = 100, .height = 20 }, rg.iconText(@intFromEnum(rg.IconName.file_add), "Add Instance"))) {
        std.debug.print("tested!\n", .{});
    }
}
