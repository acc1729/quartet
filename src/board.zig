const std = @import("std");

const DEFAULT_COST = 10;

pub const Point = struct {
    x: u8,
    y: u8,
};

const Tile = enum {
    floor,
    wall,
    water,

    pub fn repr(self: Tile) u8 {
        return switch (self) {
            Tile.floor => '.',
            Tile.wall => '#',
            Tile.water => '~',
        };
    }
};

pub const Location = struct {
    kind: Tile,
};

// Viewport for game board will be 60 by 25, but that'll include borders.
const WIDTH = 8;
const HEIGHT = 4;

pub const Map = struct {
    board: [HEIGHT][WIDTH]Location,
    const Self = @This();
    pub fn init() Map {
        var board: [HEIGHT][WIDTH]Location = undefined;
        var h: u8 = 1;
        var w: u8 = 0;
        while (w < WIDTH) : (w += 1) {
            board[0][w] = Location{ .kind = Tile.wall };

            board[HEIGHT - 1][w] = Location{ .kind = Tile.wall };
        }
        while (h < HEIGHT - 1) : (h += 1) {
            board[h][0] = Location{ .kind = Tile.wall };
            w = 1;
            while (w < WIDTH - 1) : (w += 1) {
                board[h][w] = Location{ .kind = Tile.floor };
            }

            board[h][WIDTH - 1] = Location{ .kind = Tile.wall };
        }
        return Self{.board = board};
    }
    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) @TypeOf(writer).Error!void {
        _ = options;
        _ = fmt;
        for (self.board) |row| {
            for (row) |tile| {
                try writer.writeByte(tile.kind.repr());
            }
            try writer.writeByte('\n');
        }
    }
};

const ta = std.testing.allocator;

test "Tile types have representation." {
    const floor = Tile.floor;
    try std.testing.expectEqual(floor.repr(), '.');
    const water = Tile.water;
    try std.testing.expectEqual(water.repr(), '~');
}

test "Map.init" {
    const map = Map.init();
    try std.testing.expect(map.board[0][0].kind == Tile.wall);
    try std.testing.expect(map.board[1][1].kind == Tile.floor);
    try std.testing.expect(map.board[2][1].kind == Tile.floor);
    try std.testing.expect(map.board[1][WIDTH - 1].kind == Tile.wall);
    try std.testing.expect(map.board[HEIGHT - 1][WIDTH - 1].kind == Tile.wall);
}

fn locationOnBoard(x: u16, y: u16) u16 {
    return ((y - 1) * (WIDTH + 1)) + x - 1;
}

test "Map.format" {
    const map = Map.init();
    const fmt = try std.fmt.allocPrint(ta, "{}", .{map});
    defer ta.free(fmt);
    
    try std.testing.expectEqual(fmt[0], '#');
    try std.testing.expectEqual(fmt[WIDTH], '\n');
    try std.testing.expectEqual(fmt[comptime locationOnBoard(WIDTH, HEIGHT)], '#');
}
