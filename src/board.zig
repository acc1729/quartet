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
const WIDTH = 60 - 2;
const HEIGHT = 25 - 2;

pub const Map = struct {
    tiles: *[25][80]Location,

    const Self = @This();

    pub fn init(alloc: std.mem.Allocator) !Self {
        var board = try alloc.create([25][80]Location);
        var h: u8 = 1;
        var w: u8 = 0;
        while (w < WIDTH) : (w += 1) {
            board[0][w] = Location{ .kind = Tile.wall };

            board[HEIGHT][w] = Location{ .kind = Tile.wall };
        }
        while (h < HEIGHT - 1) : (h += 1) {
            board[h][0] = Location{ .kind = Tile.wall };
            w = 1;
            while (w < WIDTH - 1) : (w += 1) {
                board[h][w] = Location{ .kind = Tile.floor };
            }

            board[h][0] = Location{ .kind = Tile.wall };
        }
        return Self{.tiles = board};
    }
    
    pub fn deinit(self: *Self, alloc: std.mem.Allocator) void {
        alloc.free(self.tiles);
    }
};

test "Tile types have representation." {
    const floor = Tile.floor;
    try std.testing.expectEqual(floor.repr(), '.');
    const water = Tile.water;
    try std.testing.expectEqual(water.repr(), '~');
}

test "Map is populated." {
    const ta = std.testing.allocator;
    const board = try Map.init(ta);
    defer ta.destroy(board);
    try std.testing.expect(board.tiles[0][0].kind == Tile.wall);
}