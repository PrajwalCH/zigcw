const std = @import("std");

pub fn takeInput(allocator: *std.mem.Allocator, max_byte: usize) ![]u8 {
    const stdin = std.io.getStdIn().reader();
    const raw_input = try stdin.readUntilDelimiterAlloc(allocator, '\n', max_byte);
    return raw_input;
}
