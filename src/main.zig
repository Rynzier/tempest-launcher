const std = @import("std");
const rg = @import("raygui");
const rl = @import("raylib");

// Internal representation of modpack instances
const TempestPack = struct {
    name: [:0]const u8,
    path: [:0]const u8,
    icon: ?rl.Texture,
};

var packArray: [64]TempestPack = [_]TempestPack{.{ .name = "", .path = "", .icon = null }} ** 64;
var packNum: i32 = 0;

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

    if (rg.button(rl.Rectangle{ .x = 4, .y = screenHeight - 24, .width = 100, .height = 20 }, rg.iconText(@intFromEnum(rg.IconName.redo), "Refresh Packs"))) {
        std.debug.print("Refreshing packs.\n", .{});
        packNum = try getPackData(std.heap.c_allocator, &packArray);
    }

    if ((try drawInstanceButton(rl.Rectangle{ .x = 50, .y = 50, .width = 200, .height = 200 }, &packArray[0])) > 0) {
        std.debug.print("Goop!\n", .{});
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
pub fn drawInstanceButton(rect: rl.Rectangle, pack: *TempestPack) !i32 {
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
    if (pack.icon) |icon| {
        rl.drawTexturePro(
            icon,
            rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(icon.width), .height = @floatFromInt(icon.height) },
            rect,
            rl.Vector2.zero(),
            0.0,
            if (state == rg.State.focused) .blue else .white,
        );
    }
    rl.drawText(pack.name, @intFromFloat(rect.x), @intFromFloat((rect.y + rect.height + 4)), 16, .gray);

    return result;
}

pub fn getPackData(alloc: std.mem.Allocator, pack_array: []TempestPack) !i32 {
    var curDir = try std.fs.cwd().openDir("test-files/instances", .{ .iterate = true });
    defer curDir.close();

    var i: usize = 0;

    var itr = curDir.iterate();
    while (try itr.next()) |entry| : (i += 1) {
        if (entry.kind == .directory) {
            const pathArray: [4][]const u8 = [_][]const u8{ "test-files", "instances", entry.name, "packicon.png" };
            const curPath: [:0]const u8 = try std.fs.path.joinZ(alloc, &pathArray);

            const instancePath: [3][]const u8 = [_][]const u8{ "test-files", "instances", entry.name };
            const curInstancePath: [:0]const u8 = try std.fs.path.joinZ(alloc, &instancePath);

            pack_array[i].path = curInstancePath;

            std.debug.print("file path: {s}\n", .{curPath});
            if (pack_array[i].icon) |icon| {
                rl.unloadTexture(icon);
            }

            pack_array[i].icon = try rl.loadTexture(curPath);

            //TODO: Implement JSON parsing to get pack name.
            pack_array[i].name = "test";
        }
    }

    return @intCast(i);
}
