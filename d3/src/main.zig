const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var args = std.process.args();
    _ = args.skip();
    const filename = args.next().?;

    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [4098]u8 = undefined;
    var res_p1: u64 = 0;
    const res_p2: u32 = 0;

    var on: bool = true;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var i: u16 = 0;
        while (i < line.len) {
            if (!on and i < line.len - 4 and std.mem.eql(u8, line[i .. i + 4], "do()")) {
                on = true;
                i += 4;
                continue;
            }
            if (on and i < line.len - 7 and std.mem.eql(u8, line[i .. i + 7], "don't()")) {
                on = false;
                i += 7;
                continue;
            }
            if (on and i < line.len - 4 and std.mem.eql(u8, line[i .. i + 4], "mul(")) {
                i += 4;
                var n1: u32 = 0;
                while (std.ascii.isDigit(line[i])) {
                    n1 = n1 * 10 + line[i] - '0';
                    i += 1;
                }
                if (line[i] != ',') {
                    continue;
                }
                i += 1;
                var n2: u32 = 0;
                while (std.ascii.isDigit(line[i])) {
                    n2 = n2 * 10 + line[i] - '0';
                    i += 1;
                }
                if (line[i] != ')') {
                    continue;
                }

                res_p1 += n1 * n2;
            }
            i += 1;
        }
    }

    try stdout.print("part1: {d}\npart2: {d}\n", .{ res_p1, res_p2 });
    try bw.flush(); // don't forget to flush!
}
