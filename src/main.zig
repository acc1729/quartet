const std = @import("std");

const m = @import("map.zig");

const NEWLINE: [1]u8 = .{'\n'};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const alloc = gpa.allocator();

pub fn main() anyerror!void {
    defer _ = gpa.deinit();
    const map = m.Map.initFromFile("test.txt");
    const stdout = std.io.getStdOut();
    const repr = try std.fmt.allocPrint(alloc, "{}", .{map});
    defer alloc.free(repr);
    _ = try stdout.write(repr);
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
