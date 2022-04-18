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

pub const Board = [HEIGHT][WIDTH]Location;
const BoardRepr = [HEIGHT][WIDTH]u8;

pub fn init(alloc: std.mem.Allocator) !*Board {
    var board = try alloc.create(Board);
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
    return board;
}

pub fn deinit(board: *Board, alloc: std.mem.Allocator) void {
    alloc.free(board.tiles);
}

pub fn toString(board: *Board, alloc: std.mem.Allocator) !*BoardRepr {
    var repr = try alloc.create(BoardRepr);
    for (board) |row, h| {
        for (row) |tile, w| {
            repr[h][w] = tile.kind.repr();
        }
    }
    return repr;
}

const ta = std.testing.allocator;

test "Tile types have representation." {
    const floor = Tile.floor;
    try std.testing.expectEqual(floor.repr(), '.');
    const water = Tile.water;
    try std.testing.expectEqual(water.repr(), '~');
}

test "Map is populated." {
    const board = try init(ta);
    defer ta.destroy(board);
    try std.testing.expect(board[0][0].kind == Tile.wall);
    try std.testing.expect(board[1][1].kind == Tile.floor);
    try std.testing.expect(board[2][1].kind == Tile.floor);
    try std.testing.expect(board[1][WIDTH - 1].kind == Tile.wall);
    try std.testing.expect(board[HEIGHT - 1][WIDTH - 1].kind == Tile.wall);
}

test "toString" {
    const board = try init(ta);
    defer ta.destroy(board);
    const repr = try toString(board, ta);
    defer ta.destroy(repr);
    try std.testing.expectEqual(repr[0][0], '#');
    try std.testing.expectEqual(repr[1][1], '.');
    try std.testing.expectEqual(repr[HEIGHT - 1][WIDTH - 1], '#');
}
