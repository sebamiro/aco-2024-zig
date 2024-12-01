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

    var buf: [1024]u8 = undefined;
    const allocator = std.heap.page_allocator;
    var col1 = ArrayList(u32).init(allocator);
    defer col1.deinit();
    var col2 = ArrayList(u32).init(allocator);
    defer col2.deinit();
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var nums = std.mem.split(u8, line, " ");
        const num1 = try std.fmt.parseInt(u32, nums.next().?, 10);
        const num2 = try std.fmt.parseInt(u32, nums.next().?, 10);
        try col1.append(num1);
        try col2.append(num2);
    }
    std.mem.sort(u32, col1.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, col2.items, {}, comptime std.sort.asc(u32));

    var res_p1: u64 = 0;
    for (col1.items, col2.items) |v1, v2| {
        if (v2 > v1) {
            res_p1 += v2 - v1;
        } else {
            res_p1 += v1 - v2;
        }
    }

    var res_p2: u64 = 0;
    for (col1.items) |v1| {
        var mult: u32 = 0;
        for (col2.items) |v2| {
            if (v1 == v2) {
                mult += 1;
            }
        }
        res_p2 += v1 * mult;
    }

    try stdout.print("part1: {d}\npart2: {d}\n", .{ res_p1, res_p2 });
    try bw.flush(); // don't forget to flush!
}
