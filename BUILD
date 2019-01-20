package(default_visibility = ["//visibility:private"])

licenses(["notice"])  # Apache 2.0

exports_files(["LICENSE"])

load("//tools/build_defs/apple:ios.bzl", "ios_framework")

ios_framework(
    name = "GTMLoadTimer",
    bundle_id = "com.google.toolbox.GTMLoadTimer",
    extension_safe = 1,
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [":Info.plist"],
    minimum_os_version = "8",
    visibility = ["//visibility:public"],
    deps = [
        ":GTMLoadTimerLib",
    ],
)

objc_library(
    name = "GTMLoadTimerLib",
    srcs = ["GTMLoadTimer.m"],
)
