const std = @import("std");

const random = @import("main.zig").random;
const resource = @import("resource.zig");

const Resource = resource.Resource;

pub const Loyalty = enum {
    Friend,
    Enemy,
};

pub const Unit = struct {
    loyalty: Loyalty,

    health: Resource,
    mana: Resource,
    movement: u8,
    speed: u8,
    strength: u8,
    constitution: u8,
    intellect: u8,
    will: u8,
    luck: u8,

    const Self = @This();

    pub fn is_lucky(self: Self) bool {
        return (random.uintLessThan(u8, 100) < self.luck);
    }

    pub fn is_dead(self: Self) bool {
        return self.health.current == 0;
    }

    pub fn attack(self: *Self, other: *Self) void {
        var damage_mod: u8 = 1;
        if (self.is_lucky()) damage_mod = 2;
        other.health.remove(self.strength * damage_mod - other.constitution);
    }

    pub fn spell(self: *Self, other: *Self) void {
        if (self.mana.current >= 3) {
            self.mana.remove(3);
            other.health.remove(self.intellect - other.will);
        }
    }

    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) @TypeOf(writer).Error!void {
        _ = fmt;
        _ = options;
        try writer.writeByte(switch (self.loyalty) {
            .Enemy => 'E',
            .Friend => 'A',
        });
    }
};

const t = std.testing;
const ta = t.allocator;

fn getDefaultUnit() Unit {
    return Unit{
        .loyalty = .Friend,
        .health = Resource{ .current = 10, .max = 10 },
        .mana = Resource{ .current = 10, .max = 10 },
        .movement = 4,
        .speed = 5,
        .strength = 6,
        .constitution = 3,
        .intellect = 8,
        .will = 6,
        .luck = 4,
    };
}

test "Unit.is_dead" {
    var unit = getDefaultUnit();
    unit.health.current = 0;
    try std.testing.expect(unit.is_dead());
}

test "Units can fight." {
    var attacker = getDefaultUnit();
    var defender = getDefaultUnit();

    attacker.attack(&defender);
    try std.testing.expect(defender.health.current < defender.health.max);
}

test "Units can spellcast." {
    var attacker = getDefaultUnit();
    var defender = getDefaultUnit();

    attacker.spell(&defender);
    try std.testing.expect(defender.health.current < defender.health.max);
    try std.testing.expect(attacker.mana.current < attacker.mana.max);

    const pre_fizzle_health = defender.health.current;
    attacker.mana.current = 1;

    attacker.spell(&defender);
    try std.testing.expect(defender.health.current == pre_fizzle_health);
}

test "Unit.format" {
    const attacker = getDefaultUnit();
    const fmt = try std.fmt.allocPrint(ta, "{}", .{attacker});
    defer ta.free(fmt);
    try t.expectEqualSlices(u8, fmt, "A");
}
