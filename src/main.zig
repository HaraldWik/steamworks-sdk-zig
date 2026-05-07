const std = @import("std");
const Io = std.Io;

const steam = @import("steamworks_sdk");

pub fn main(init: std.process.Init) !void {
    _ = init;
    try steam.init();
    defer steam.shutdown();
}
