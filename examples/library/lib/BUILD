load("@rules_idris//idris:rules_idris.bzl", "idris_library", "idris_test")

idris_library (
    name = "library_example",
    visibility = ["//visibility:public"],
)

idris_test (
    name = "test_example",
    deps = ["@IdrisTest//idristest:idristest", "library_example"],
)


