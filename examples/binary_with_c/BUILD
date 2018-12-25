load("@rules_idris//idris:rules_idris.bzl", "idris_binary")

idris_binary (
    name = "binary_example",
    libs = ["salute"],
)

cc_library (
    name = "salute",
    srcs = ["main.cpp"],
    hdrs = ["main.h"],
)
