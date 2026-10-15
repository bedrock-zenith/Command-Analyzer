const std = @import("std");

pub const CommandInfo = struct {
    command_enums: []CommandEnum,
    commands: []Command,
    module_type: []u8,
    name: []u8,
};

pub const CommandEnum = struct {
    name: []u8,
    values: []struct { value: []u8 },
};

pub const Command = struct {
    aliases: []struct { name: []u8 },
    description: []u8,
    name: []u8,
    overloads: []Overload,
    permission_level: u8,
    requires_cheats: bool,
};

pub const Overload = struct {
    name: []u8,
    params: []Param,
};

pub const Param = struct {
    is_optional: bool,
    name: []u8,
    type: struct { name: []u8 },
};
