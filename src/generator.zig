const std = @import("std");

pub const type_fixes: std.StaticStringMap([]const u8) = .initComptime(&.{
    .{ "char", "u8" },

    .{ "int", "c_int" },
    .{ "unsigned int", "c_uint" },
    .{ "short", "c_short" },
    .{ "unsigned short", "c_ushort" },
    .{ "long", "c_long" },
    .{ "unsigned long", "c_ulong" },
    .{ "long long", "c_longlong" },
    .{ "unsigned long long", "c_ulonglong" },
    .{ "signed short", "c_short" },
    .{ "signed int", "c_int" },

    .{ "uint8", "u8" },
    .{ "uint8_t", "u8" },
    .{ "int8", "i8" },
    .{ "int8_t", "i8" },

    .{ "uint16", "u16" },
    .{ "uint16_t", "u16" },
    .{ "int16", "i16" },
    .{ "int16_t", "i16" },

    .{ "uint32", "u32" },
    .{ "uint32_t", "u32" },
    .{ "int32", "i32" },

    .{ "uint64", "u64" },
    .{ "uint64_t", "u64" },
    .{ "int64", "i64" },

    .{ "float", "f32" },
    .{ "double", "f64" },

    .{ "ID", "Id" },

    .{ "APICall", "ApiCall" },
});

pub const Json = struct {
    callback_structs: []const CallbackStruct,
    consts: []const Const,
    enums: []const Enum,
    interfaces: []const Interface,
};

pub const CallbackStruct = struct {
    callback_id: u32,
    enums: []const Enum = &.{},
    fields: []const Struct.Field = &.{},
    @"struct": []const u8,
};

pub const Const = struct {
    constname: []const u8,
    consttype: []const u8,
    constval: []const u8,
};

pub const Enum = struct {
    enumname: []const u8,
    fqname: ?[]const u8 = null,
    values: []struct {
        name: []const u8,
        value: []const u8,
    },

    pub fn format(self: @This(), w: *std.Io.Writer) std.Io.Writer.Error!void {
        try w.writeAll("pub const ");
        try emitType(w, self.enumname);
        try w.writeAll(" = enum(c_int) {\n");
        for (self.values) |value| {
            const name = std.mem.trimStart(u8, std.mem.trimStart(u8, std.mem.trimStart(u8, value.name, "k_"), self.enumname), "_");
            if (name.len == 0) {
                try w.writeAll("default");
            } else {
                if (std.ascii.isDigit(name[0])) try w.writeAll("@\"");
                try w.writeAll(name);
                if (std.ascii.isDigit(name[0])) try w.writeByte('"');
            }
            try w.print(" = {s},\n", .{value.value});
        }
        try w.writeAll("};\n");
    }
};

pub const Interface = struct {
    accessors: []const Accessors = &.{},
    classname: []const u8,
    // fields: []const ?,
    methods: []const Method = &.{},

    pub const Accessors = struct {
        kind: []const u8,
        name: []const u8,
        name_flat: []const u8,
    };

    pub const Method = struct {
        methodname: []const u8,
        methodname_flat: []const u8,
        params: []const Param,
        returntype: []const u8,

        pub const Param = struct {
            paramname: []const u8,
            paramtype: []const u8,
        };

        pub fn format(self: @This(), w: *std.Io.Writer) std.Io.Writer.Error!void {
            try w.writeAll("extern fn ");
            try w.writeAll(self.methodname_flat);
            try w.writeByte('(');
            for (self.params, 0..) |param, i| {
                try w.writeAll(param.paramname);
                try w.writeByte(':');
                try emitType(w, param.paramtype);

                if (i != self.params.len - 1) try w.writeByte(',');
            }
            try w.writeAll(") ");
            try emitType(w, self.returntype);
            try w.writeAll(";\n");

            var underscore_count: usize = 0;
            const name_start: usize = for (self.methodname_flat, 0..) |c, i| {
                if (c == '_') underscore_count += 1;
                if (underscore_count == 2) break i + 1;
            } else 0;

            const name = self.methodname_flat[name_start..];
            try w.print("pub const {c}{s} = {s};\n", .{ std.ascii.toLower(name[0]), name[1..], self.methodname_flat });
        }
    };

    pub fn format(self: @This(), w: *std.Io.Writer) std.Io.Writer.Error!void {
        try w.writeAll("pub const ");
        try w.writeAll(std.mem.trimStart(u8, self.classname, "ISteam"));
        try w.writeAll(" = packed struct {\nhandle: c_int = 0,");
        for (self.methods) |method| {
            try method.format(w);
        }
        try w.writeAll("};\n");
    }
};

pub const Struct = struct {
    methods: []Interface.Method,
    @"struct": []const u8,

    pub const Field = struct {
        fieldname: []const u8,
        fieldtype: []const u8,
    };
};

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;
    var args = try init.minimal.args.iterateAllocator(gpa);
    _ = args.skip();
    const json_path = args.next() orelse return error.NoJson;
    const output_path = args.next() orelse return error.NoOutput;

    std.log.info("in: {s}", .{json_path});
    std.log.info("out: {s}", .{output_path});

    const json_file = try std.Io.Dir.openFileAbsolute(io, json_path, .{});
    defer json_file.close(io);
    var json_reader = json_file.reader(io, &.{});
    const json_data = try json_reader.interface.allocRemaining(gpa, .unlimited);
    defer gpa.free(json_data);

    const json_parsed: std.json.Parsed(Json) = try std.json.parseFromSlice(Json, gpa, json_data, .{ .ignore_unknown_fields = true });
    defer json_parsed.deinit();

    var output_writer: std.Io.Writer.Allocating = .init(gpa);
    defer output_writer.deinit();
    try emit(&output_writer.writer, json_parsed.value);

    var output_file = try std.Io.Dir.createFileAbsolute(io, output_path, .{});
    defer output_file.close(io);
    try output_file.writeStreamingAll(io, @embedFile("core.zig"));
    // try output_file.writeStreamingAll(io, output_writer.writer.buffered());
    // var output_file_writer_buffer: [4096]u8 = undefined;
    // var output_file_writer = output_file.writer(io, &output_file_writer_buffer);
    // try output_file_writer.interface.writeAll(@embedFile("core.zig"));

    // const generated = try output_writer.toOwnedSliceSentinel(0);
    // defer gpa.free(generated);

    // var tree = try std.zig.Ast.parse(gpa, generated, .zig);
    // defer tree.deinit(gpa);

    // if (tree.errors.len != 0) {
    //     try std.zig.printAstErrorsToStderr(gpa, io, tree, output_path, .auto);
    //     return error.ParseError;
    // }

    // try tree.render(gpa, &output_file_writer.interface, .{});
    // try output_file_writer.interface.flush();
}

pub fn emit(w: *std.Io.Writer, json: Json) std.Io.Writer.Error!void {
    for (json.enums) |e| try e.format(w);
    for (json.interfaces) |interface| try interface.format(w);

    // for (json.consts) |c| {
    //     try w.print("pub const {s}: {s} = {s};\n", .{ std.mem.trimStart(u8, c.constname, "k_"), type_fixes.get(c.consttype) orelse c.consttype, c.constval });
    // }

    // for (json.callback_structs) |callback| {
    //     try w.print("pub const {s} = struct {{\n", .{callback.@"struct"});
    //     for (callback.fields) |field| {
    //         try w.print("{s}: {s},\n", .{ std.mem.trimStart(u8, field.fieldname, "m_"), type_fixes.get(field.fieldtype) orelse field.fieldtype });
    //     }
    //     try w.writeAll("};\n");
    // }

}

pub fn emitType(w: *std.Io.Writer, raw: []const u8) std.Io.Writer.Error!void {
    var s = std.mem.trim(u8, raw, " ");

    var is_const = false;
    if (std.mem.startsWith(u8, s, "const ")) {
        is_const = true;
        s = s[6..];
    }

    var ptr_depth: usize = 0;

    for (s) |c| switch (c) {
        '*', '&' => ptr_depth += 1,
        else => {},
    };

    const name: []const u8 = name: {
        var start: usize = for (s, 0..) |c, i| {
            if (std.ascii.isAlphanumeric(c) or c == '_') break i;
        } else unreachable;

        var end: usize = s.len;

        for (s[start..], 0..) |c, i| if (!std.ascii.isAlphanumeric(c) or c == '_' or c == ' ') {
            end = start + i;
            break;
        };

        if (std.mem.find(u8, s[start..end], "Steam")) |index| start += index + 5;
        if (std.mem.endsWith(u8, s[start..end], "_t")) end -= 2;

        break :name s[start..end];
    };

    for (0..ptr_depth) |_| try w.writeAll("[*c]");
    if (is_const and ptr_depth > 0) try w.writeAll("const ");

    try w.writeAll(type_fixes.get(name) orelse name);
}
