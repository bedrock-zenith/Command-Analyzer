const std = @import("std");
const Io = std.Io;

const command_analyzer = @import("root.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const cwd: std.Io.Dir = .cwd();
    const file = try cwd.openFile(io, "main.mcfunction", .{
        .mode = .read_only,
    });

    var buffer: [65536]u8 = undefined;
    const read = try file.readPositionalAll(io, &buffer, 0);
    const data = buffer[0..read];

    var parser: command_analyzer.Parser = .{ .source = data };

    std.log.debug("identifier: {?s}", .{parser.name()});
    std.log.debug("identifier: {?s}", .{parser.identifier()});
}
