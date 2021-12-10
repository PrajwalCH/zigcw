const std = @import("std");
const takeInput = @import("take_input.zig").takeInput;
const Command = @import("command.zig").Command;

const debug = std.debug;
const allocator = std.heap.page_allocator;

pub fn start() !void {
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

        var command = Command.parse(user_guess);
        switch (command) {
            Command.Skip => continue,
            Command.Quit => break,
            Command.Word => {
                if (std.mem.eql(u8, original_word, user_guess)) {
                    debug.print("You guessed it correctly\n\n", .{});
                } else {
                    debug.print("Oops you guessed it wrong, correct word is '{s}'\n\n", .{original_word});
                }
            },
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

fn takeUserGuess(word_len: usize) ![]u8 {
    debug.print("> ", .{});
    var input = try takeInput(allocator, 100);
    return input;
}

fn genRandomNum(from: usize, to: usize) !usize {
    var seed: usize = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));

    var prng = std.rand.DefaultPrng.init(seed);
    var rand = &prng.random;

    return rand.intRangeAtMost(usize, from, to);
}
