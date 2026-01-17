const std = @import("std");
const rg = @import("raygui");
const rl = @import("raylib");

// Internal representation of modpack instances
const TempestPack = struct {
    name: [:0]const u8,
    path: []u8,
    icon: rl.Texture,
};

const screenHeight = 720;
const screenWidth = 720;

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
    _ = rg.panel(rl.Rectangle{ .x = screenWidth - 180, .y = 0, .width = 180, .height = screenHeight }, null);

    _ = rg.panel(rl.Rectangle{ .x = 0, .y = 0, .width = screenWidth, .height = 28 }, null);
    _ = rg.panel(rl.Rectangle{ .x = 0, .y = screenHeight - 28, .width = screenWidth, .height = 28 }, null);

    if (rg.button(rl.Rectangle{ .x = 4, .y = 4, .width = 100, .height = 20 }, rg.iconText(@intFromEnum(rg.IconName.file_add), "Add Instance"))) {
        std.debug.print("adding instance.\n", .{});
    }

    if (rg.button(rl.Rectangle{ .x = 108, .y = 4, .width = 100, .height = 20 }, rg.iconText(@intFromEnum(rg.IconName.file_open), "Open Folders"))) {
        std.debug.print("opening folders.\n", .{});
    }

    // Path to Instances
    // test-files/instances/<instance_01>
    //
    // Path to Installations
    // test-files/vs-globeba/1-21-6
    //
    // Path to launcher settings
    // test-files/launcher-settings.json

}

// Makes it easy to draw instance icon/buttons
pub fn drawInstanceButton(rect: rl.Rectangle, pack: *TempestPack) i32 {
    var result: i32 = 0;
    var state: rg.State = rg.getState();

    // Control logic
    if ((state != rg.State.disabled) and !rg.isLocked()) { // missing check for gui exclusive mode
        const mousePoint: rl.Vector2 = rl.getMousePosition();

        if (rl.CheckCollisionPointRec(mousePoint, rect)) {
            if (rl.isMouseButtonDown(rl.MouseButton.left)) {
                state = rg.State.pressed;
            } else {
                state = rg.State.focused;
            }

            if (rl.isMouseButtonReleased(rl.MouseButton.left)) result = 1;
        }
    }

    // Draw the control
    rl.drawTexturePro(
        pack.icon,
        rl.Rectangle{ .x = 0, .y = 0, .width = pack.icon.width, .height = pack.icon.height },
        rect,
        rl.Vector2.zero(),
        0.0,
        .white,
    );
    rl.drawText(pack.name, rect.x, (rect.y + rect.height + 4), 24, .gray);
}

pub fn getPackData(alloc: std.mem.Allocator, pack_array: []TempestPack) !void {
    var curDir = try std.fs.cwd().openDir("test-files", .{ .iterate = true });
    defer curDir.close();

    var i: usize = 0;

    var itr = curDir.iterate();
    while (try itr.next()) |entry| : (i += 1) {
        if (entry.kind == .directory) {
            var curInstance: std.fs.Dir = curDir.openDir(entry.name, .{});
            defer curInstance.close();

            const prePath: []const u8 = entry.name;
            const pathArray: [2][]const u8 = [_]u8{ prePath, "modicon.png" };
            const curPath: []const u8 = std.fs.path.join(alloc, pathArray);
            _ = curPath;
            _ = pack_array;
        }
    }
}
