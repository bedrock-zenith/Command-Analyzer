//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;

pub const Parser = struct {
    source: []const u8,
    cursor: usize = 0,

    pub fn name(parser: *@This()) ?[]const u8 {
        return identifier(parser);
    }

    pub fn identifier(parser: *@This()) ?[]const u8 {
        if (parser.cursor >= parser.source.len) {
            return null;
        }

        drain(parser);
        const start = parser.cursor;

        while (parser.cursor < parser.source.len and isContinuous(parser.source[parser.cursor])) {
            parser.cursor += 1;
        }

        if (start == parser.cursor) {
            return null;
        }

        return parser.source[start..parser.cursor];
    }

    pub fn drain(parser: *@This()) void {
        while (parser.cursor < parser.source.len and isWhiteSpace(parser.source[parser.cursor])) {
            parser.cursor += 1;
        }
    }

    pub fn branch(self: @This()) @This() {
        return self;
    }
};

pub inline fn isWhiteSpace(char: anytype) bool {
    return switch (char) {
        ' ', '\n', '\r' => true,
        else => false,
    };
}

pub inline fn isContinuous(char: anytype) bool {
    return switch (char) {
        'a'...'z', 'A'...'Z', '0'...'9', '_' => true,
        else => false,
    };
}

pub const CommandArgument = union(enum) {
    enumerable: [][]const u8,
    integer,
    decimal,
    target,
    json,
};

pub const CommandGraph = struct {
    name: []const u8,
};

pub const CommandEnum = struct {
    pub fn validate() bool {}
};
pub const CommandTarget = struct {
    pub fn validate() bool {}
};

pub const CommandType = union(enum) {
    enumerable: CommandEnum,
    integer: void,
    decimal: void,
    string: void,
    target: CommandTarget,
};

pub const CommandNode = struct {
    type: CommandType,
    pub fn next() []CommandNode {}
};

pub const CommandParserContext = struct {
    branches: []const Parser,
};

// - We need to create some kind of graph and being able to eliminate dead branches later on
// - We should store the parsers in single continuous memory region
// - Each branch could produce some others, but shouldn't ever exceed more than 64?? /execute has like 16 or something
// - Elimination should be done early based on the enum type
// - We can optimize with enum unions, if every type in root of each branch has same type we can just parse it once and resolve right after
//  branches shouldn't collide too much, but might afaik?
// -
//

//
