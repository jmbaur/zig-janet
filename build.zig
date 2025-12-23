const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const janet_dep = b.dependency("janet", .{});

    const janetconf = b.addConfigHeader(
        .{ .style = .blank, .include_path = "janetconf.h" },
        .{
            .JANET_VERSION_MAJOR = 1,
            .JANET_VERSION_MINOR = 40,
            .JANET_VERSION_PATCH = 1,
            .JANET_VERSION_EXTRA = "",
            .JANET_VERSION = "1.40.1",
        },
    );

    const cflags: []const []const u8 = &.{ "-std=c99", "-fvisibility=hidden" };

    const janet_boot = b.addExecutable(.{
        .name = "janet-boot",
        .root_module = b.createModule(.{
            .optimize = .Debug,
            .target = b.graph.host,
            .link_libc = true,
            .pic = true,
        }),
    });

    janet_boot.addCSourceFiles(.{
        .root = janet_dep.path(""),
        .flags = cflags ++ .{"-DJANET_BOOTSTRAP"},
        .files = &.{
            // boot
            "src/boot/array_test.c",
            "src/boot/boot.c",
            "src/boot/buffer_test.c",
            "src/boot/number_test.c",
            "src/boot/system_test.c",
            "src/boot/table_test.c",

            // core
            "src/core/abstract.c",
            "src/core/array.c",
            "src/core/asm.c",
            "src/core/buffer.c",
            "src/core/bytecode.c",
            "src/core/capi.c",
            "src/core/cfuns.c",
            "src/core/compile.c",
            "src/core/corelib.c",
            "src/core/debug.c",
            "src/core/emit.c",
            "src/core/ev.c",
            "src/core/ffi.c",
            "src/core/fiber.c",
            "src/core/filewatch.c",
            "src/core/gc.c",
            "src/core/inttypes.c",
            "src/core/io.c",
            "src/core/marsh.c",
            "src/core/math.c",
            "src/core/net.c",
            "src/core/os.c",
            "src/core/parse.c",
            "src/core/peg.c",
            "src/core/pp.c",
            "src/core/regalloc.c",
            "src/core/run.c",
            "src/core/specials.c",
            "src/core/state.c",
            "src/core/string.c",
            "src/core/strtod.c",
            "src/core/struct.c",
            "src/core/symcache.c",
            "src/core/table.c",
            "src/core/tuple.c",
            "src/core/util.c",
            "src/core/value.c",
            "src/core/vector.c",
            "src/core/vm.c",
            "src/core/wrap.c",
        },
    });
    janet_boot.addIncludePath(janet_dep.path("src/include"));
    janet_boot.addConfigHeader(janetconf);

    const janet_boot_run = b.addRunArtifact(janet_boot);
    janet_boot_run.addDirectoryArg(janet_dep.path(""));
    const janet_c = janet_boot_run.captureStdOut();

    const janet_lib = b.addLibrary(.{
        .name = "janet",
        .root_module = b.createModule(.{
            .optimize = optimize,
            .target = target,
            .strip = optimize != .Debug,
            .link_libc = true,
            .pic = true,
        }),
    });
    janet_lib.addCSourceFile(.{ .file = janet_c, .flags = cflags, .language = .c });
    janet_lib.addIncludePath(janet_dep.path("src/include"));
    janet_lib.addConfigHeader(janetconf);
    janet_lib.installHeader(janetconf.getOutputFile(), "janetconf.h");
    janet_lib.installHeadersDirectory(janet_dep.path("src/include"), "", .{});
    b.installArtifact(janet_lib);

    const janet = b.addExecutable(.{
        .name = "janet",
        .root_module = b.createModule(.{
            .optimize = optimize,
            .target = target,
            .strip = optimize != .Debug,
            .link_libc = true,
            .pic = true,
        }),
    });
    janet.addCSourceFiles(.{
        .root = janet_dep.path(""),
        .flags = cflags,
        .files = &.{"src/mainclient/shell.c"},
    });
    janet.addIncludePath(janet_dep.path("src/include"));
    janet.addConfigHeader(janetconf);
    janet.linkLibrary(janet_lib);

    b.installArtifact(janet);
}
