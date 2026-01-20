const std = @import("std");

const Backend = enum {
    none,
    sdl2,
    sdl3,
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const backend = b.option(Backend, "backend", "Audio backend to use") orelse .none;

    const al_dep = b.dependency("openal-soft", .{});

    const libal = b.addLibrary(.{
        .name = "al",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .link_libcpp = true,
        }),
    });
    libal.addIncludePath(al_dep.path(""));
    libal.addIncludePath(al_dep.path("common"));
    libal.addIncludePath(al_dep.path("gsl/include"));
    libal.addIncludePath(al_dep.path("fmt-11.2.0/include"));
    libal.addIncludePath(al_dep.path("include"));
    libal.addIncludePath(al_dep.path("include/AL"));
    libal.installHeadersDirectory(al_dep.path("include"), "", .{});

    const version = b.addConfigHeader(.{
        .style = .{ .cmake = al_dep.path("version.h.in") },
        .include_path = "version.h",
    }, .{
        .LIB_VERSION = "1.25.0",
        .LIB_VERSION_NUM = "1,25,0,0",
        .GIT_BRANCH = "master",
        .GIT_COMMIT_HASH = "75c00596307bf05ba7bbc8c7022836bf52f17477",
    });
    libal.root_module.addConfigHeader(version);

    const config = b.addConfigHeader(.{
        .style = .{ .cmake = al_dep.path("config.h.in") },
        .include_path = "config.h",
    }, .{
        .ALSOFT_FORCE_ALIGN = "__attribute__((force_align_arg_pointer))",
        .ALSOFT_EMBED_HRTF_DATA = 0,
        .HAVE_PROC_PIDPATH = 0,
        .HAVE_DLFCN_H = 0,
        .HAVE_PTHREAD_NP_H = 0,
        .HAVE_CPUID_H = 0,
        .HAVE_INTRIN_H = 0,
        .HAVE_GUIDDEF_H = 0,
        .HAVE_GCC_GET_CPUID = 0,
        .HAVE_CPUID_INTRINSIC = 0,
        .HAVE_PTHREAD_SETSCHEDPARAM = 0,
        .HAVE_PTHREAD_SETNAME_NP = 0,
        .HAVE_PTHREAD_SET_NAME_NP = 0,
        .ALSOFT_INSTALL_DATADIR = "core/al",
        .HAVE_DLOPEN_NOTES = 0,
        .HAVE_CXXMODULES = 0,
        .HAVE_RTKIT = 0,
        .ALSOFT_UWP = 0,
        .ALSOFT_EAX = 0,
    });
    libal.root_module.addConfigHeader(config);

    const config_simd = b.addConfigHeader(.{
        .style = .{ .cmake = al_dep.path("config_simd.h.in") },
        .include_path = "config_simd.h",
    }, .{
        .HAVE_SSE = @intFromBool(target.result.cpu.arch == .x86_64),
        .HAVE_SSE2 = @intFromBool(target.result.cpu.arch == .x86_64),
        .HAVE_SSE3 = @intFromBool(target.result.cpu.arch == .x86_64),
        .HAVE_SSE4_1 = @intFromBool(target.result.cpu.arch == .x86_64),
        .HAVE_SSE_INTRINSICS = @intFromBool(target.result.cpu.arch == .x86_64),
        .HAVE_NEON = 0,
    });
    libal.root_module.addConfigHeader(config_simd);

    const config_backends = b.addConfigHeader(.{
        .style = .{ .cmake = al_dep.path("config_backends.h.in") },
        .include_path = "config_backends.h",
    }, .{
        .HAVE_ALSA = 0,
        .HAVE_OSS = 0,
        .HAVE_PIPEWIRE = 0,
        .HAVE_SOLARIS = 0,
        .HAVE_SNDIO = 0,
        .HAVE_WASAPI = 0,
        .HAVE_DSOUND = 0,
        .HAVE_WINMM = 0,
        .HAVE_PORTAUDIO = 0,
        .HAVE_PULSEAUDIO = 0,
        .HAVE_JACK = 0,
        .HAVE_COREAUDIO = 0,
        .HAVE_OPENSL = 0,
        .HAVE_OBOE = 0,
        .HAVE_WAVE = 0,
        .HAVE_SDL2 = backend == .sdl2,
        .HAVE_SDL3 = backend == .sdl3,
    });
    libal.root_module.addConfigHeader(config_backends);

    const defines: []const []const u8 = &.{
        "-std=c++20",
        "-DFMT_HEADER_ONLY",
        "-DAL_LIBTYPE_STATIC",
        "-DAL_ALEXT_PROTOTYPES",
    };

    libal.root_module.addCSourceFiles(.{
        .flags = defines,
        .files = &.{
            "common/alcomplex.cpp",
            "common/almalloc.cpp",
            "common/alstring.cpp",
            "common/althrd_setname.cpp",
            "common/dynload.cpp",
            "common/filesystem.cpp",
            "common/pffft.cpp",
            "common/polyphase_resampler.cpp",
            "common/strutils.cpp",
            "core/ambdec.cpp",
            "core/ambidefs.cpp",
            "core/bformatdec.cpp",
            "core/bs2b.cpp",
            "core/bsinc_tables.cpp",
            "core/context.cpp",
            "core/converter.cpp",
            "core/cpu_caps.cpp",
            "core/cubic_tables.cpp",
            "core/devformat.cpp",
            "core/device.cpp",
            "core/effectslot.cpp",
            "core/except.cpp",
            "core/filters/biquad.cpp",
            "core/filters/nfc.cpp",
            "core/filters/splitter.cpp",
            "core/fpu_ctrl.cpp",
            "core/helpers.cpp",
            "core/hrtf.cpp",
            "core/hrtf_loader.cpp",
            "core/hrtf_resource.cpp",
            "core/logging.cpp",
            "core/mastering.cpp",
            "core/mixer.cpp",
            "core/storage_formats.cpp",
            "core/tsmefilter.cpp",
            "core/uhjfilter.cpp",
            "core/uiddefs.cpp",
            "core/voice.cpp",
            "core/mixer/mixer_c.cpp",
            "al/auxeffectslot.cpp",
            "al/buffer.cpp",
            "al/debug.cpp",
            "al/effect.cpp",
            "al/effects/autowah.cpp",
            "al/effects/chorus.cpp",
            "al/effects/compressor.cpp",
            "al/effects/convolution.cpp",
            "al/effects/dedicated.cpp",
            "al/effects/distortion.cpp",
            "al/effects/echo.cpp",
            "al/effects/effects.cpp",
            "al/effects/equalizer.cpp",
            "al/effects/fshifter.cpp",
            "al/effects/modulator.cpp",
            "al/effects/null.cpp",
            "al/effects/pshifter.cpp",
            "al/effects/reverb.cpp",
            "al/effects/vmorpher.cpp",
            "al/error.cpp",
            "al/event.cpp",
            "al/extension.cpp",
            "al/filter.cpp",
            "al/listener.cpp",
            "al/source.cpp",
            "al/state.cpp",
            "alc/alc.cpp",
            "alc/alu.cpp",
            "alc/alconfig.cpp",
            "alc/context.cpp",
            "alc/device.cpp",
            "alc/effects/autowah.cpp",
            "alc/effects/chorus.cpp",
            "alc/effects/compressor.cpp",
            "alc/effects/convolution.cpp",
            "alc/effects/dedicated.cpp",
            "alc/effects/distortion.cpp",
            "alc/effects/echo.cpp",
            "alc/effects/equalizer.cpp",
            "alc/effects/fshifter.cpp",
            "alc/effects/modulator.cpp",
            "alc/effects/null.cpp",
            "alc/effects/pshifter.cpp",
            "alc/effects/reverb.cpp",
            "alc/effects/vmorpher.cpp",
            "alc/events.cpp",
            "alc/panning.cpp",
            "alc/backends/base.cpp",
            "alc/backends/loopback.cpp",
            "alc/backends/null.cpp",
        },
        .root = al_dep.path(""),
    });

    libal.root_module.addCSourceFiles(.{
        .flags = defines,
        .files = switch (backend) {
            .sdl2 => &.{ "alc/backends/sdl2.cpp" },
            .sdl3 => &.{ "alc/backends/sdl3.cpp" },
            .none => &.{},
        },
        .root = al_dep.path(""),
    });

    switch (target.result.cpu.arch) {
        .x86_64 => {
            libal.root_module.addCSourceFiles(.{
                .flags = defines,
                .files = &.{
                    "core/mixer/mixer_sse.cpp",
                    "core/mixer/mixer_sse2.cpp",
                    "core/mixer/mixer_sse3.cpp",
                    "core/mixer/mixer_sse41.cpp",
                },
                .root = al_dep.path(""),
            });
        },
        else => {},
    }

    b.installArtifact(libal);
}
