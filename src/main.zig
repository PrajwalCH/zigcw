const std = @import("std");

pub fn main() anyerror!void {
    while (true) {
        printMenu();

        const choosen_menu = takeUserInput() catch |err| switch (err) {
            error.Overflow => {
                std.debug.print("Number is too big\n", .{});
                continue;
            },
            error.InvalidCharacter => {
                std.debug.print("Please enter a valid number\n", .{});
                continue;
            },
            else => {
                std.debug.print("Unhandled error occured\n", .{});
                continue;
            },
        };

        if (choosen_menu == 1) {
            startGame();
        } else if (choosen_menu == 2) {
            std.debug.print("[Game Exited]\n", .{});
            break;
        } else {
            std.debug.print("Unknown menu option\n", .{});
            continue;
        }
    }
}

fn printMenu() void {
    std.debug.print("1. Start\n", .{});
    std.debug.print("2. Exit\n", .{});
}

fn takeUserInput() !u8 {
    const stdin = std.io.getStdIn().reader();

    std.debug.print("> ", .{});
    const raw_input = try stdin.readUntilDelimiterAlloc(std.heap.page_allocator, '\n', 8192);
    defer std.heap.page_allocator.free(raw_input);

    const choosen_menu = try std.fmt.parseInt(u8, raw_input, 10);
    return choosen_menu;
}

fn startGame() void {
    // read words from.file and allocate buffer
    // shuffle the words buffer
    // iterate words buffer
    // shuffle a word and ask to user for guess
    // check if user guess it or not
    // continue no matter what
}
