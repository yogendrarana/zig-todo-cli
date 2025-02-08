const std = @import("std");
const todo = @import("todo.zig");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const check = gpa.deinit();
        if (check == .leak) {
            @panic("Memory leak detected!");
        }
    }
    const allocator = gpa.allocator();

    var todoList = todo.TodoList.init(allocator);
    defer todoList.deinit();

    const stdout = std.io.getStdOut().writer();
    var buffer: [1024]u8 = undefined;

    while (true) {
        try stdout.print("\nTodo App Commands:\n", .{});
        try stdout.print("1. Add todo\n2. List todos\n3. Toggle todo\n4. Exit\n", .{});
        try stdout.print("Choose command (1-4): ", .{});

        const input = try std.io.getStdIn().reader().readUntilDelimiter(&buffer, '\n');

        if (std.mem.eql(u8, input, "1")) {
            try stdout.print("Enter todo content: ", .{});
            const content = try std.io.getStdIn().reader().readUntilDelimiter(&buffer, '\n');
            try todoList.addItem(content);
            try stdout.print("Todo added!\n", .{});
        } else if (std.mem.eql(u8, input, "2")) {
            try todoList.listItems(stdout);
        } else if (std.mem.eql(u8, input, "3")) {
            try stdout.print("Enter todo ID to toggle: ", .{});
            const id_input = try std.io.getStdIn().reader().readUntilDelimiter(&buffer, '\n');
            const id = try std.fmt.parseInt(usize, id_input, 10);
            todoList.toggleItem(id) catch {
                try stdout.print("Todo with ID {d} not found!\n", .{id});
                continue;
            };
            try stdout.print("Todo toggled!\n", .{});
        } else if (std.mem.eql(u8, input, "4")) {
            break;
        } else {
            try stdout.print("Invalid command!\n", .{});
        }
    }
}
