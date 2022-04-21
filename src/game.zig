const std = @import("std");

const m = @import("map.zig");
const unit = @import("unit.zig");
pub const Game = struct {
    map: m.Map,
    units: []unit,
    round: u16,

    const Self = @This();

    pub fn init(filename: []const u8) !Self {
        return Self{
            .map = try m.Map.initFromFile(filename),
            .units = &.{},
            .round = 0,
        };
    }
};

const t = std.testing;

test "Game.init" {
    const game = try Game.init("test.txt");
    try t.expectEqual(game.round, 0);
    try t.expect(game.map.board[3][3].kind.repr() == '~');
}
