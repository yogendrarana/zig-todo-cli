const std = @import("std");

// Todo item structure
pub const TodoItem = struct {
    id: usize,
    content: []const u8,
    completed: bool,
};

pub const TodoList = struct {
    items: std.ArrayList(TodoItem),
    nextId: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) TodoList {
        return @This(){
            .items = std.ArrayList(TodoItem).init(allocator),
            .nextId = 1,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *TodoList) void {
        // Free the content of each todo item
        for (self.items.items) |item| {
            self.allocator.free(item.content);
        }
        self.items.deinit();
    }

    pub fn addItem(self: *TodoList, content: []const u8) !void {
        const dupedContent = try self.allocator.dupe(u8, content);
        const item = TodoItem{
            .id = self.nextId,
            .content = dupedContent,
            .completed = false,
        };
        try self.items.append(item);
        self.nextId += 1;
    }

    pub fn listItems(self: *TodoList, writer: anytype) !void {
        if (self.items.items.len == 0) {
            try writer.print("No todos found!\n", .{});
            return;
        }

        for (self.items.items) |item| {
            const status = if (item.completed) "X" else " ";
            try writer.print("[{s}] {d}. {s}\n", .{ status, item.id, item.content });
        }
    }

    pub fn toggleItem(self: *TodoList, id: usize) !void {
        for (self.items.items) |*item| {
            if (item.id == id) {
                item.completed = !item.completed;
                return;
            }
        }
        return error.ItemNotFound;
    }
};
