const std = @import("std");
const debug = std.debug;

const allocater = std.heap.page_allocator;

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
            startGame() catch |err| switch (err) {
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

    const stdin = std.io.getStdIn().reader();
    const raw_input = try stdin.readUntilDelimiterAlloc(allocator, '\n', 8192);
    defer allocator.free(raw_input);

    const choosen_menu = try std.fmt.parseInt(u8, raw_input, 10);
    return choosen_menu;
}

fn startGame() !void {
    var words = try readWordsFile("words.dict");
    defer {
        for (words.items) |item| {
            allocator.free(item);
        }
        words.deinit();
    }
    try shuffleWordsBuf(words.items);

    for (words.items) |original_word| {
        try makeAndPrintCringeWord(original_word);
        var user_guess = takeUserGuess(original_word.len) catch |err| switch (err) {
            error.StreamTooLong => {
                debug.print("Your guess is too long\n", .{});
                continue;
            },
            else => |e| return e,
        };
        defer allocator.free(user_guess);

        if (!std.mem.eql(u8, original_word[0..], user_guess[0..])) {
            debug.print("Oops you loose\n", .{});
            debug.print("You guess: {s}\n", .{user_guess});
            debug.print("Correct word is: {s}\n\n", .{original_word});
            continue;
        } else {
            debug.print("You guess correct\n", .{});
            continue;
        }
    }
}

fn readWordsFile(filename: []const u8) !std.ArrayList([]u8) {
    var file = try std.fs.cwd().openFile(filename, .{ .read = true, .write = false });
    defer file.close();

    var words = std.ArrayList([]u8).init(allocator);

    while (try file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 100)) |line| {
        try words.append(line);
    }
    return words;
}

fn shuffleWordsBuf(words: [][]u8) !void {
    for (words) |_, i| {
        const idx = (words.len - 1) - i;
        const rand_idx = try genRandomNum(0, idx);

        const last_byte: []u8 = words[idx];
        words[idx] = words[rand_idx];
        words[rand_idx] = last_byte;
    }
}

fn makeAndPrintCringeWord(original_word: []const u8) !void {
    var cringe_word = try std.mem.dupe(allocator, u8, original_word);
    defer allocator.free(cringe_word);

    try makeCringeWord(cringe_word);
    debug.print("What is the correct form of '{s}'?\n", .{cringe_word});
}

fn makeCringeWord(word: []u8) !void {
    for (word) |_, i| {
        const idx = (word.len - 1) - i;
        const rand_idx = try genRandomNum(0, idx);

        const last_byte: u8 = word[idx];
        word[idx] = word[rand_idx];
        word[rand_idx] = last_byte;
    }
}

fn genRandomNum(from: usize, to: usize) !usize {
    var seed: usize = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));

    var prng = std.rand.DefaultPrng.init(seed);
    var rand = &prng.random;

    return rand.intRangeAtMost(usize, from, to);
}

fn takeUserGuess(word_len: usize) ![]u8 {
    const stdin = std.io.getStdIn().reader();
    var input = try stdin.readUntilDelimiterAlloc(allocator, '\n', word_len);
    return input;
}
