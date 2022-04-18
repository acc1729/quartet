const std = @import("std");

const board = @import("board.zig");

const NEWLINE: [1]u8 = .{'\n'};

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const map = try board.init(alloc);
    defer alloc.destroy(map);
    const stdout = std.io.getStdOut();
    const repr = try board.toString(map, alloc);
    defer alloc.destroy(repr);
    for (repr) |*line| {
        _ = try stdout.write(line);
        _ = try stdout.write(&NEWLINE);
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
