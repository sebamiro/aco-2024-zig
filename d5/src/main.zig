const std = @import("std");
const ArrayList = std.ArrayList;

const Token = struct { c: u8, right: ?u64, d_left: ?u64, d_under: ?u64, d_right: ?u64, u_left: ?u64, u_right: ?u64 };
const TokenList = std.MultiArrayList(Token);

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

    const allocator = std.heap.page_allocator;
    var list = std.ArrayList(u8).init(allocator);

    const res_p1: u64 = 0;
    const res_p2: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            break;
        }
        var nums = std.mem.splitAny(u8, line, "|");
        std.debug.assert(nums.peek() != null);
        const lsh: u8 = try std.fmt.parseInt(u8, nums.next().?, 10);
        const rsh: u8 = try std.fmt.parseInt(u8, nums.next().?, 10);

        const ilsh = contains(list.items, lsh);
        const irsh = contains(list.items, rsh);

        if (ilsh) |i| {
            if (irsh) |j| {
                std.debug.print("List contains lsh {d}[{d}] and rsh {d}[{d}]\n", .{lsh, i, rsh, j});
                if (i < j) continue;
            } else {
                try list.append(rsh);
            }
        } else if (irsh) |i| {
            try list.insert(0, lsh);
        } else {
            try list.insert(0, lsh);
            try list.append(rsh);
        }
    }

    try stdout.print("part1: {d}\npart2: {d}\n", .{ res_p1, res_p2 });
    try bw.flush();
}

fn contains(slice: []u8, n: u8) ?usize {
    for (slice, 0..) |s, i| {
        if (s == n) return i;
    }
    return null;
}
