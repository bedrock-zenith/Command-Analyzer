const std = @import("std");
const Io = std.Io;
const command_data = @import("command_data.zig");
const CommandInfo = command_data.CommandInfo;

const command_analyzer = @import("root.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const cwd: std.Io.Dir = .cwd();
    {
        const start = std.Io.Clock.now(.awake, io).toMilliseconds();
        const mojang_command_file = try cwd.openFile(io, "mojang-commands.json", .{ .mode = .read_only });
        defer mojang_command_file.close(io);

        var buffer: [2048]u8 = undefined;
        var reader = mojang_command_file.reader(io, &buffer);

        var jsonReader: std.json.Reader = .init(init.gpa, &reader.interface);
        defer jsonReader.deinit();

        const command_info_parsed = std.json.parseFromTokenSource(CommandInfo, init.gpa, &jsonReader, .{}) catch unreachable;
        defer command_info_parsed.deinit();
        const command_info = command_info_parsed.value;

        var command_map: std.StringHashMap(*command_data.Command) = .init(init.gpa);
        defer command_map.deinit();

        for (command_info.commands) |*command| {
            try command_map.put(command.name, command);
        }

        var enum_map: std.StringHashMap(*command_data.CommandEnum) = .init(init.gpa);
        defer enum_map.deinit();

        for (command_info.command_enums) |*@"enum"| {
            // TODO allocate new string, so original name doesn't get shi on
            // std.ascii.lowerString(@constCast(@"enum".name), @"enum".name);
            try enum_map.put(std.ascii.lowerString(@constCast(@"enum".name), @"enum".name), @"enum");
        }

        const total = std.Io.Clock.now(.awake, io).toMilliseconds() - start;
        std.debug.print("time: {}\n", .{total});
        std.debug.print("commands_length: {}\n", .{command_map.unmanaged.size});
        std.debug.print("commands_enums: {}\n", .{enum_map.unmanaged.size});
    }

    {
        const file = try cwd.openFile(io, "main.mcfunction", .{
            .mode = .read_only,
        });
        defer file.close(io);

        var buffer: [65536]u8 = undefined;
        const read = try file.readPositionalAll(io, &buffer, 0);
        const data = buffer[0..read];
        _ = data; // autofix
    }
}
