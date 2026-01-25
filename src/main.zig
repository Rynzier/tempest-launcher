const std = @import("std");
const rg = @import("raygui");
const rl = @import("raylib");

// Internal representation of modpack instances
const TempestPack = struct {
    name: ?[:0]const u8 = null,
    path: []u8,
    icon: ?rl.Texture = null,
};

const screenHeight = 720;
const screenWidth = 720;

var packArray: [64]TempestPack = undefined;

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

    if (rg.button(rl.Rectangle{ .x = 4, .y = screenHeight - 24, .width = 120, .height = 20 }, rg.iconText(@intFromEnum(rg.IconName.redo), "Refresh Packs"))) {
        std.debug.print("refreshing.\n", .{});
        try getPackData(std.heap.c_allocator, &packArray);
    }

    if (packArray[0].icon != null and packArray[0].name != null) {
        _ = drawInstanceButton(rl.Rectangle{ .x = 100, .y = 100, .width = 100, .height = 100 }, &packArray[0]);
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
    var state: rg.State = @enumFromInt(rg.getState());

    // Control logic
    if ((state != rg.State.disabled) and !rg.isLocked()) { // missing check for gui exclusive mode
        const mousePoint: rl.Vector2 = rl.getMousePosition();

        if (rl.checkCollisionPointRec(mousePoint, rect)) {
            if (rl.isMouseButtonDown(rl.MouseButton.left)) {
                state = rg.State.pressed;
            } else {
                state = rg.State.focused;
            }

            if (rl.isMouseButtonReleased(rl.MouseButton.left)) result = 1;
        }
    }

    // Draw the control
    if (pack.icon) |aIcon| {
        rl.drawTexturePro(
            aIcon,
            rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(aIcon.width), .height = @floatFromInt(aIcon.height) },
            rect,
            rl.Vector2.zero(),
            0.0,
            .white,
        );
    }
    // const textX: i32 = @intFromFloat(rect.x);
    // const textY: i32 = @intFromFloat(rect.y + rect.height + 4);
    // rl.drawText(pack.name, textX, textY, 24, .gray);
    rl.drawText("goop", 100, 100, 25, .gray);
    return result;
}

pub fn getPackData(alloc: std.mem.Allocator, pack_array: []TempestPack) !void {
    var curDir = try std.fs.cwd().openDir("test-files/instances", .{ .iterate = true });
    defer curDir.close();

    var i: usize = 0;

    var itr = curDir.iterate();
    while (try itr.next()) |entry| : (i += 1) {
        if (entry.kind == .directory) {
            var curInstance: std.fs.Dir = try curDir.openDir(entry.name, .{});
            defer curInstance.close();

            const pathArray: [4][]const u8 = .{ "test-files", "instances", entry.name, "packicon.png" };
            const finalPath: [:0]u8 = try std.fs.path.joinZ(alloc, &pathArray);

            if (pack_array[i].icon != null) {
                rl.unloadTexture(pack_array[i].icon.?);
            }
            pack_array[i].icon = try rl.loadTexture(finalPath);

            const packConfig: []u8 = try curInstance.readFileAlloc(alloc, "packconfig.json", 1024);
            _ = packConfig;
        }
    }
}
