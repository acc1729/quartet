const std = @import("std");

const m = @import("map.zig");
const unit = @import("unit.zig");
pub const Game = struct {
    map: m.Map,
    units: []unit,
    round: u16,

    const Self = @This();

    pub fn init() Self {
        return Self{
            .map = m.Map.init(),
            .units = &.{},
            .round = 0,
        };
    }
};

const t = std.testing;

test "Game.init" {
    const game = Game.init();
    try t.expectEqual(game.round, 0);
}
