const std = @import("std");

pub const Resource = struct {
    max: u16,
    current: u16 = 0,

    const Self = @This();

    pub fn add(self: *Self, amount: u16) void {
        self.current = self.current + amount;
        if (self.current > self.max) {
            self.current = self.max;
        }
    }
    pub fn remove(self: *Self, amount: u16) void {
        if (amount >= self.current) {
            self.current = 0;
        } else {
            self.current = self.current - amount;
        }
    }
    pub fn ratio(self: Self) f32 {
        return @intToFloat(f32, self.current) / @intToFloat(f32, self.max);
    }
};

test "basic math" {
    var health = Resource{ .current = 12, .max = 15 };
    health.add(2);
    try std.testing.expectEqual(health.current, 14);
    health.remove(8);
    try std.testing.expectEqual(health.current, 6);
}

test "clamps to max" {
    var health = Resource{ .current = 12, .max = 15 };
    health.add(12);
    try std.testing.expectEqual(health.current, 15);
}

test "clamps to zero" {
    var health = Resource{ .current = 12, .max = 15 };
    health.remove(20);
    try std.testing.expectEqual(health.current, 0);
}

test "ratio" {
    var health = Resource{ .current = 12, .max = 15 };
    try std.testing.expectEqual(health.ratio(), 0.8);
}
