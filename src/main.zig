const std = @import("std");
const game = @import("game.zig");
const takeInput = @import("take_input.zig").takeInput;

const debug = std.debug;
const allocator = std.heap.page_allocator;

pub fn main() anyerror!void {
    while (true) {
        printMenu();

        const choosen_menu = takeUserInput() catch |err| switch (err) {
            error.Overflow => {
                debug.print("Number is too big\n", .{});
                continue;
            },
            error.InvalidCharacter => {
                debug.print("Please enter a valid number\n", .{});
                continue;
            },
            else => {
                debug.print("Unhandled error occured\n", .{});
                continue;
            },
        };

        if (choosen_menu == 1) {
            game.start() catch |err| switch (err) {
                error.FileNotFound => {
                    debug.warn("'words.dict' data file not found\n", .{});
                    break;
                },
                else => |e| return e,
            };
        } else if (choosen_menu == 2) {
            debug.print("[Game Exited]\n", .{});
            break;
        } else {
            debug.print("Unknown menu option\n", .{});
            continue;
        }
    }
}

fn printMenu() void {
    debug.print("1. Start\n", .{});
    debug.print("2. Exit\n", .{});
}

fn takeUserInput() !u8 {
    debug.print("> ", .{});

    const raw_input = try takeInput(allocator, 8192);
    defer allocator.free(raw_input);

    const choosen_menu = try std.fmt.parseInt(u8, raw_input, 10);
    return choosen_menu;
}
