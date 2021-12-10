const mem = @import("std").mem;

const SKIP_CMD = ".s";
const QUIT_CMD = ".q";

pub const Command = enum {
    Skip,
    Quit,
    Word,

    pub fn parse(input: []u8) Command {
        if (mem.eql(u8, input, SKIP_CMD))
            return Command.Skip;
        if (mem.eql(u8, input, QUIT_CMD))
            return Command.Quit;
        return Command.Word;
    }
};
