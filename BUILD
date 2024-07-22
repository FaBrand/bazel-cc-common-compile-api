load(":rule.bzl", "cc_behaviour")

cc_behaviour(
    name = "with_other_name",
    srcs = ["simple_source.cpp"],
    hdrs = ["v1/simple_header.h"],
    other_name = "other_name",
    strip_include_prefix = "v1",
)

cc_behaviour(
    name = "with_label_name",
    srcs = ["simple_source.cpp"],
    hdrs = ["v1/simple_header.h"],
    strip_include_prefix = "v1",
)
