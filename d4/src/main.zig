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
    var list = TokenList{};
    defer list.deinit(allocator);

    var x_list = std.ArrayList(u64).init(allocator);
    defer x_list.deinit();
    var s_list = std.ArrayList(u64).init(allocator);
    defer s_list.deinit();
    var a_list = std.ArrayList(u64).init(allocator);
    defer a_list.deinit();

    var res_p1: u64 = 0;
    var res_p2: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line, 0..) |c, i| {
            if (c == 'X') try x_list.append(list.len);
            if (c == 'S') try s_list.append(list.len);
            if (c == 'A') try a_list.append(list.len);
            try list.append(allocator, .{
                .c = c,
                .right = if (i + 1 < line.len) list.len + 1 else null,
                .u_left = if (i > 0 and list.len > line.len) list.len - line.len - 1 else null,
                .u_right = if (i + 1 < line.len and list.len > line.len + 1) list.len - line.len + 1 else null,
                .d_left = if (i > 0) line.len + list.len - 1 else null,
                .d_under = line.len + list.len,
                .d_right = if (i + 1 < line.len) line.len + list.len + 1 else null,
            });
        }
    }

    const chars = list.items(.c);
    for (x_list.items) |i| {
        if (assert_word(chars, list.items(.right), i, "MAS")) res_p1 += 1;
        if (assert_word(chars, list.items(.d_left), i, "MAS")) res_p1 += 1;
        if (assert_word(chars, list.items(.d_under), i, "MAS")) res_p1 += 1;
        if (assert_word(chars, list.items(.d_right), i, "MAS")) res_p1 += 1;
    }

    for (s_list.items) |i| {
        if (assert_word(chars, list.items(.right), i, "AMX")) res_p1 += 1;
        if (assert_word(chars, list.items(.d_left), i, "AMX")) res_p1 += 1;
        if (assert_word(chars, list.items(.d_under), i, "AMX")) res_p1 += 1;
        if (assert_word(chars, list.items(.d_right), i, "AMX")) res_p1 += 1;
    }

    for (a_list.items) |i| {
        if (assert_cross(chars, list.get(i))) {
            res_p2 += 1;
        }
    }

    try stdout.print("TOKEN_LIST {d} | X_LIST: {d} | S_LIST: {d} | A_LIST: {d}\n", .{ list.slice().len, x_list.items.len, s_list.items.len, a_list.items.len });

    try stdout.print("part1: {d}\npart2: {d}\n", .{ res_p1, res_p2 });
    try bw.flush(); // don't forget to flush!
}

fn assert_word(chars: []u8, path: []?u64, i: u64, word: *const [3:0]u8) bool {
    var cur = i;

    for (word) |c| {
        const e = path[cur];
        if (!assert_char(chars, e, c)) {
            return false;
        }
        cur = e.?;
    }
    return true;
}

fn assert_cross(chars: []u8, t: Token) bool {
    if (t.u_left == null) return false;
    if (t.u_right == null) return false;
    if (t.d_left == null or t.d_left.? > chars.len) return false;
    if (t.d_right == null or t.d_right.? > chars.len) return false;

    if (chars[t.u_left.?] == 'M') {
        if (chars[t.d_right.?] != 'S') {
            return false;
        }
    } else if (chars[t.u_left.?] == 'S') {
        if (chars[t.d_right.?] != 'M') {
            return false;
        }
    } else {
        return false;
    }

    if (chars[t.d_left.?] == 'M') {
        if (chars[t.u_right.?] != 'S') {
            return false;
        }
    } else if (chars[t.d_left.?] == 'S') {
        if (chars[t.u_right.?] != 'M') {
            return false;
        }
    } else {
        return false;
    }
    return true;
}

fn assert_char(chars: []u8, i: ?u64, expect: u8) bool {
    if (i == null or i.? >= chars.len) return false;

    return chars[i.?] == expect;
}
