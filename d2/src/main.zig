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
    var res_p1: u32 = 0;
    var res_p2: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var nums = std.mem.split(u8, line, " ");

        var first: i32 = try std.fmt.parseInt(i32, nums.next().?, 10);
        var second: i32 = try std.fmt.parseInt(i32, nums.next().?, 10);

        var damper: bool = false;
        var safe_p1: u32 = 1;
        var safe_p2: u32 = 1;
        var diff: i32 = 0;

        while (nums.next()) |n| {
            const third: i32 = try std.fmt.parseInt(i32, n, 10);
            if (is_valid(first, second, third, diff)) {
                first = second;
                second = third;
                diff = second - first;
                continue;
            }
            try stdout.print("{s} | INVALID: [{d} -> {d} -> {d}]\n", .{ line, first, second, third });

            safe_p1 = 0;
            if (damper) {
                try stdout.print("{s} | ## ERROR ##\n", .{line});
                safe_p2 = 0;
                break;
            }
            damper = true;

            const num = nums.next();
            if (num == null) {
                try stdout.print("{s} | SKIP \n", .{line});
                break;
            }

            const fourth: i32 = try std.fmt.parseInt(i32, num.?, 10);

            if (is_valid(second, third, fourth, diff)) {
                try stdout.print("{s} | PREV FIX #1: [{d} -> {d} -> {d} ]\n", .{ line, second, third, fourth });
                first = third;
                second = fourth;
                try stdout.print("{s} | FIX #1: [{d} -> {d} -> . ]\n", .{ line, first, second });
                continue;
            }

            if (is_valid(first, third, fourth, diff)) {
                first = third;
                second = fourth;
                try stdout.print("{s} | FIX #2: [{d} -> {d} -> .]\n", .{ line, first, second });
                continue;
            }

            if (is_valid(first, second, fourth, diff)) {
                first = second;
                second = fourth;
                try stdout.print("{s} | FIX #3: [{d} -> {d} -> .]\n", .{ line, first, second });
                continue;
            }

            try stdout.print("{s} | ## FERROR ##\n", .{line});
            safe_p2 = 0;
            break;
        }
        res_p1 += safe_p1;
        if (safe_p2 > 0) {
            try stdout.print("{s} | ## OK ##\n", .{line});
        }
        res_p2 += safe_p2;
    }

    try stdout.print("part1: {d}\npart2: {d}\n", .{ res_p1, res_p2 });
    try bw.flush(); // don't forget to flush!
}

fn is_valid(first: i32, second: i32, third: i32, diff: i32) bool {
    const diff1 = second - first;
    const diff2 = third - second;

    if (first == second or second == third or first == third) {
        return false;
    }
    if (@abs(diff1) > 3 or @abs(diff2) > 3) {
        return false;
    }
    if (diff != 0) {
        return (diff < 0 and diff1 < 0 and diff2 < 0) or (diff > 0 and diff1 > 0 and diff2 > 0);
    }
    return (diff1 < 0 and diff2 < 0) or (diff1 > 0 and diff2 > 0);
}
