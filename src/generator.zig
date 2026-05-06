const std = @import("std");

pub const type_fixes: std.StaticStringMap([]const u8) = .initComptime(&.{
    .{ "int", "c_int" },
    .{ "unsigned int", "c_uint" },
    .{ "uint16", "u16" },
    .{ "uint32", "u32" },
    .{ "const char *", "?[*:0]const u8" },
});

pub const Json = struct {
    callback_structs: []CallbackStruct,
    consts: []Const,

    pub const CallbackStruct = struct {
        callback_id: u32,
        enums: []const struct {
            enumname: []const u8,
            fqname: []const u8,
            values: []struct {
                name: []const u8,
                value: u32,
            },
        } = &.{},
        fields: []const struct {
            fieldname: []const u8,
            fieldtype: []const u8,
        } = &.{},
        @"struct": []const u8,
    };

    pub const Const = struct {
        constname: []const u8,
        consttype: []const u8,
        constval: []const u8,
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

    var file = try std.Io.Dir.createFileAbsolute(io, output_path, .{});
    defer file.close(io);
    try file.writeStreamingAll(io, @embedFile("core.zig"));
    // try file.writeStreamingAll(io, output_writer.writer.buffered());
}

pub fn emit(w: *std.Io.Writer, json: Json) std.Io.Writer.Error!void {
    for (json.consts) |c| {
        try w.print("pub const {s}: {s} = {s};\n", .{ std.mem.trimStart(u8, c.constname, "k_"), type_fixes.get(c.consttype) orelse c.consttype, c.constval });
    }

    for (json.callback_structs) |callback| {
        try w.print("pub const {s} = struct {{\n", .{callback.@"struct"});
        for (callback.fields) |field| {
            try w.print("{s}: {s},\n", .{ std.mem.trimStart(u8, field.fieldname, "m_"), type_fixes.get(field.fieldtype) orelse field.fieldtype });
        }
        try w.writeAll("};\n");
    }
}
