"""Actual implementations"""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

def _cc_behaviour_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    name = ctx.attr.other_name if ctx.attr.other_name else ctx.label.name
    (compilation_context, compilation_outputs) = cc_common.compile(
        name = name,
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        public_hdrs = ctx.files.hdrs,
        srcs = ctx.files.srcs,
        strip_include_prefix = ctx.attr.strip_include_prefix,
    )

    (linking_context, linking_outputs) = cc_common.create_linking_context_from_compilation_outputs(
        name = name,
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        language = "c++",
        compilation_outputs = compilation_outputs,
    )

    library = linking_outputs.library_to_link
    files = [
        library.pic_static_library,
        library.static_library,
        library.dynamic_library,
    ]
    files.extend(compilation_outputs.objects)
    files.extend(compilation_outputs.pic_objects)

    cc_info = CcInfo(
        compilation_context = compilation_context,
        linking_context = linking_context,
    )

    return [
        cc_info,
        DefaultInfo(
            files = depset([f for f in files if f != None]),
        ),
    ]

cc_behaviour = rule(
    implementation = _cc_behaviour_impl,
    attrs = {
        "hdrs": attr.label_list(allow_files = True),
        "other_name": attr.string(),
        "srcs": attr.label_list(allow_files = True),
        "strip_include_prefix": attr.string(),
        "_cc_toolchain": attr.label(default = "@bazel_tools//tools/cpp:current_cc_toolchain"),
    },
    fragments = ["cpp"],
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)
