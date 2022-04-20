const std = @import("std");

const DEFAULT_COST = 10;

pub const Point = struct {
    x: u8,
    y: u8,
};

const MapError = error{TileError};

const Tile = enum {
    Floor,
    Wall,
    Water,

    pub fn repr(self: Tile) u8 {
        return switch (self) {
            .Floor => '.',
            .Wall => '#',
            .Water => '~',
        };
    }

    pub fn fromRepr(char: u8) !Tile {
        return switch (char) {
            '.' => .Floor,
            '#' => .Wall,
            '~' => .Water,
            else => MapError.TileError,
        };
    }
};

pub const Location = struct {
    kind: Tile,
};

// Viewport for game board will be 60 by 25, but that'll include borders.
const WIDTH = 60;
const HEIGHT = 25;

const Board = [HEIGHT][WIDTH]Location;

pub const Map = struct {
    board: Board,
    const Self = @This();
    pub fn init() Self {
        var board: Board = undefined;
        var h: u8 = 1;
        var w: u8 = 0;
        while (w < WIDTH) : (w += 1) {
            board[0][w] = Location{ .kind = Tile.Wall };

            board[HEIGHT - 1][w] = Location{ .kind = Tile.Wall };
        }
        while (h < HEIGHT - 1) : (h += 1) {
            board[h][0] = Location{ .kind = Tile.Wall };
            w = 1;
            while (w < WIDTH - 1) : (w += 1) {
                board[h][w] = Location{ .kind = Tile.Floor };
            }

            board[h][WIDTH - 1] = Location{ .kind = Tile.Wall };
        }
        return Self{ .board = board };
    }

    pub fn initFromFile(filename: []const u8) !Self {
        var board: Board = undefined;
        const cwd = std.fs.cwd();
        const static = try cwd.openDir("static", .{.iterate = false});
            
        var file = try static.openFile(filename, .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var input_stream = buf_reader.reader();

        var buf: [256]u8 = undefined;
        var h: u8 = 0;
        while (try input_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            for (line) |char, w| {
                board[h][w] = Location{.kind = try Tile.fromRepr(char)};
            }
            h += 1;
        }
        return Self{ .board = board };
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

const t = std.testing;
const ta = t.allocator;

test "Tile.repr" {
    const floor = Tile.Floor;
    try t.expectEqual(floor.repr(), '.');
    const water = Tile.Water;
    try t.expectEqual(water.repr(), '~');
}

test "Tile.fromRepr" {
    const floor = try Tile.fromRepr('.');
    try t.expect(floor == Tile.Floor);
}

test "Map.init" {
    const map = Map.init();
    try t.expect(map.board[0][0].kind == Tile.Wall);
    try t.expect(map.board[1][1].kind == Tile.Floor);
    try t.expect(map.board[2][1].kind == Tile.Floor);
    try t.expect(map.board[1][WIDTH - 1].kind == Tile.Wall);
    try t.expect(map.board[HEIGHT - 1][WIDTH - 1].kind == Tile.Wall);
}

test "Map.initFromFile" {
    const filename = "test.txt";
    const map = try Map.initFromFile(filename);
    
    try t.expect(map.board[0][0].kind == Tile.Wall);
    try t.expect(map.board[2][3].kind == Tile.Water);
}

fn locationOnBoard(x: u16, y: u16) u16 {
    return ((y - 1) * (WIDTH + 1)) + x - 1;
}

test "Map.format" {
    const map = Map.init();
    const fmt = try std.fmt.allocPrint(ta, "{}", .{map});
    defer ta.free(fmt);

    try t.expectEqual(fmt[0], '#');
    try t.expectEqual(fmt[WIDTH], '\n');
    try t.expectEqual(fmt[comptime locationOnBoard(WIDTH, HEIGHT)], '#');
}
