const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const steamworks_sdk = b.dependency("steamworks_sdk", .{});

    const generator = b.addExecutable(.{
        .name = "generator",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/generator.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run = b.addRunArtifact(generator);
    run.addFileArg(steamworks_sdk.path("public/steam/steam_api.json"));
    const output = run.addOutputFileArg("steam_api.zig");
    run.color = switch (std.Io.Terminal.Mode.detect(b.graph.io, .stderr(), false, false) catch .no_color) {
        .no_color => .disable,
        else => .enable,
    };

    const mod = b.addModule("steamworks_sdk", .{
        .root_source_file = output,
        .target = target,
    });

    const bin_path = switch (target.result.os.tag) {
        .windows => "redistributable_bin/win64",
        .linux => switch (target.result.cpu.arch) {
            .arm, .armeb, .thumb, .thumbeb => "redistributable_bin/linuxarm64",
            .x86_64 => if (target.result.ptrBitWidth() == 32)
                "redistributable_bin/linux32"
            else
                "redistributable_bin/linux64",
            else => "redistributable_bin/",
        },
        else => "redistributable_bin/",
    };
    mod.addLibraryPath(steamworks_sdk.path(bin_path));
    mod.linkSystemLibrary("steam_api", .{ .needed = true, .preferred_link_mode = .static });

    const exe = b.addExecutable(.{
        .name = "steamworks_sdk_example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "steamworks_sdk", .module = mod },
            },
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
}
