"""
Wrappers and helpers around `rules_pkg` to build codeql packs.
"""

load("@rules_pkg//pkg:install.bzl", "pkg_install")
load("@rules_pkg//pkg:mappings.bzl", "pkg_attributes", "pkg_filegroup", "pkg_files", _strip_prefix = "strip_prefix")
load("@rules_pkg//pkg:pkg.bzl", "pkg_zip")
load("@rules_pkg//pkg:providers.bzl", "PackageFilegroupInfo", "PackageFilesInfo")
load("@rules_python//python:defs.bzl", "py_binary")

def _make_internal(name):
    def internal(suffix = "internal"):
        return "%s-%s" % (name, suffix)

    return internal

_PLAT_DETECTION_ATTRS = {
    "_windows": attr.label(default = "@platforms//os:windows"),
    "_macos": attr.label(default = "@platforms//os:macos"),
}

_PLAT_PLACEHOLDER = "{CODEQL_PLATFORM}"

def _process_path(path, plat):
    if _PLAT_PLACEHOLDER in path:
        path = path.replace(_PLAT_PLACEHOLDER, plat)
        return ("arch", path)
    return ("generic", path)

def _detect_plat(ctx):
    if ctx.target_platform_has_constraint(ctx.attr._windows[platform_common.ConstraintValueInfo]):
        return "windows64"
    elif ctx.target_platform_has_constraint(ctx.attr._macos[platform_common.ConstraintValueInfo]):
        return "osx64"
    else:
        return "linux64"

def codeql_pkg_files(
        *,
        name,
        srcs = None,
        exes = None,
        visibility = None,
        **kwargs):
    """ Wrapper around `pkg_files` adding a distinction between `srcs` and `exes`, where the
    latter will get executable permissions.
    """

    internal = _make_internal(name)
    if "attributes" in kwargs:
        fail("do not use attributes with codeql_pkg_* rules. Use `exes` to mark executable files.")
    internal_srcs = []
    if srcs and exes:
        pkg_files(
            name = internal("srcs"),
            srcs = srcs,
            visibility = ["//visibility:private"],
            **kwargs
        )
        pkg_files(
            name = internal("exes"),
            srcs = exes,
            visibility = ["//visibility:private"],
            attributes = pkg_attributes(mode = "755"),
            **kwargs
        )
        pkg_filegroup(
            name = name,
            srcs = [internal("srcs"), internal("exes")],
            visibility = visibility,
        )
    else:
        pkg_files(
            name = name,
            srcs = srcs or exes,
            visibility = visibility,
            attributes = pkg_attributes(mode = "755") if exes else None,
            **kwargs
        )

def _extract_pkg_filegroup_impl(ctx):
    src = ctx.attr.src[PackageFilegroupInfo]
    plat = _detect_plat(ctx)

    if src.pkg_dirs or src.pkg_symlinks:
        fail("`pkg_dirs` and `pkg_symlinks` are not supported for codeql packaging rules")

    pkg_files = []
    for pfi, origin in src.pkg_files:
        dest_src_map = {}
        for dest, file in pfi.dest_src_map.items():
            file_kind, dest = _process_path(dest, plat)
            if file_kind == ctx.attr.kind:
                dest_src_map[dest] = file
        if dest_src_map:
            pkg_files.append((PackageFilesInfo(dest_src_map = dest_src_map, attributes = pfi.attributes), origin))

    files = [depset(pfi.dest_src_map.values()) for pfi, _ in pkg_files]
    return [
        PackageFilegroupInfo(pkg_files = pkg_files, pkg_dirs = [], pkg_symlinks = []),
        DefaultInfo(files = depset(transitive = files)),
    ]

_extrac_pkg_filegroup = rule(
    implementation = _extract_pkg_filegroup_impl,
    attrs = {
        "src": attr.label(providers = [PackageFilegroupInfo, DefaultInfo]),
        "kind": attr.string(doc = "generic or arch", values = ["generic", "arch"]),
    } | _PLAT_DETECTION_ATTRS,
)

def _imported_zips_manifest_impl(ctx):
    plat = _detect_plat(ctx)

    manifest = []
    files = []
    for zip, prefix in ctx.attr.zips.items():
        zip_kind, prefix = _process_path(prefix, plat)
        if zip_kind == ctx.attr.kind:
            zip_files = zip.files.to_list()
            manifest += ["%s:%s" % (prefix, f.short_path) for f in zip_files]
            files += zip_files

    output = ctx.actions.declare_file(ctx.label.name + ".params")
    ctx.actions.write(
        output,
        "\n".join(manifest),
    )
    return DefaultInfo(
        files = depset([output]),
        runfiles = ctx.runfiles(files),
    )

_imported_zips_manifest = rule(
    implementation = _imported_zips_manifest_impl,
    attrs = {
        "zips": attr.label_keyed_string_dict(allow_files = True),
        "kind": attr.string(doc = "generic or arch", values = ["generic", "arch"]),
    } | _PLAT_DETECTION_ATTRS,
)

def _zipmerge_impl(ctx):
    zips = []
    filename = ctx.attr.zip_name + "-"
    plat = _detect_plat(ctx)
    filename = "%s-%s.zip" % (ctx.attr.zip_name, plat if ctx.attr.kind == "arch" else "generic")
    output = ctx.actions.declare_file(filename)
    args = [output.path, "--prefix=%s" % ctx.attr.zip_prefix, ctx.file.base.path]
    for zip, prefix in ctx.attr.zips.items():
        zip_kind, prefix = _process_path(prefix, plat)
        if zip_kind == ctx.attr.kind:
            args.append("--prefix=%s/%s" % (ctx.attr.zip_prefix, prefix.rstrip("/")))
            args += [f.path for f in zip.files.to_list()]
            zips.append(zip.files)
    ctx.actions.run(
        outputs = [output],
        executable = ctx.executable._zipmerge,
        inputs = depset([ctx.file.base], transitive = zips),
        arguments = args,
    )

    return [
        DefaultInfo(files = depset([output])),
    ]

_zipmerge = rule(
    implementation = _zipmerge_impl,
    attrs = {
        "base": attr.label(allow_single_file = True),
        "zips": attr.label_keyed_string_dict(allow_files = True),
        "zip_name": attr.string(),
        "kind": attr.string(doc = "generic or arch", values = ["generic", "arch"]),
        "zip_prefix": attr.string(),
        "_zipmerge": attr.label(default = "//misc/bazel/internal/zipmerge", executable = True, cfg = "exec"),
    } | _PLAT_DETECTION_ATTRS,
)

def codeql_pack(
        *,
        name,
        srcs = None,
        zips = None,
        zip_filename = "extractor",
        visibility = None,
        install_dest = "extractor-pack",
        **kwargs):
    """
    Define a codeql pack. This macro accepts `pkg_files`, `pkg_filegroup` or their `codeql_*` counterparts as `srcs`.
    `zips` is a map from prefixes to `.zip` files to import.
    * defines a `<name>-generic-zip` target creating a `<zip_filename>-generic.zip` archive with the generic bits,
      prefixed with `name`
    * defines a `<name>-arch-zip` target creating a `<zip_filename>-<codeql_platform>.zip` archive with the
      arch-specific bits, prefixed with `zip_prefix` (`name` by default)
    * defines a runnable `<name>-installer` target that will install the pack in `install_dest`, relative to where the
      rule is used. The install destination can be overridden appending `-- --destdir=...` to the `bazel run`
      invocation. This installation does not use the `zip_prefix`.

    The distinction between arch-specific and generic contents is made based on whether the paths (including possible
    prefixes added by rules) contain the special `{CODEQL_PLATFORM}` placeholder, which in case it is present will also
    be replaced by the appropriate platform (`linux64`, `windows64` or `osx64`).
    """
    internal = _make_internal(name)
    zip_filename = zip_filename or name
    zips = zips or {}
    pkg_filegroup(
        name = internal("base"),
        srcs = srcs,
        visibility = ["//visibility:private"],
        **kwargs
    )
    for kind in ("generic", "arch"):
        _extrac_pkg_filegroup(
            name = internal(kind),
            src = internal("base"),
            kind = kind,
            visibility = ["//visibility:private"],
        )
        pkg_zip(
            name = internal(kind + "-zip-base"),
            srcs = [internal(kind)],
            visibility = ["//visibility:private"],
        )
        _zipmerge(
            name = internal(kind + "-zip"),
            base = internal(kind + "-zip-base"),
            zips = zips,
            zip_name = zip_filename,
            zip_prefix = name,
            kind = kind,
            visibility = visibility,
        )
        _imported_zips_manifest(
            name = internal(kind + "-zip-manifest"),
            zips = zips,
            kind = kind,
            visibility = ["//visibility:private"],
        )

    pkg_install(
        name = internal("script"),
        srcs = [internal("generic"), internal("arch")],
        visibility = ["//visibility:private"],
    )
    native.filegroup(
        # used to locate current src directory
        name = internal("build-file"),
        srcs = ["BUILD.bazel"],
        visibility = ["//visibility:private"],
    )
    py_binary(
        name = internal("installer"),
        srcs = ["//misc/bazel/internal:install.py"],
        main = "//misc/bazel/internal:install.py",
        data = [
            internal("build-file"),
            internal("script"),
            internal("generic-zip-manifest"),
            internal("arch-zip-manifest"),
            "//misc/bazel/internal/ripunzip",
        ],
        deps = ["@rules_python//python/runfiles"],
        args = [
            "--build-file=$(rlocationpath %s)" % internal("build-file"),
            "--script=$(rlocationpath %s)" % internal("script"),
            "--destdir",
            install_dest,
            "--ripunzip=$(rlocationpath //misc/bazel/internal/ripunzip)",
            "--zip-manifest=$(rlocationpath %s)" % internal("generic-zip-manifest"),
            "--zip-manifest=$(rlocationpath %s)" % internal("arch-zip-manifest"),
        ],
        visibility = visibility,
    )
    native.filegroup(
        name = name,
        srcs = [internal("generic-zip"), internal("arch-zip")],
    )

strip_prefix = _strip_prefix

def _runfiles_group_impl(ctx):
    files = []
    for src in ctx.attr.srcs:
        rf = src[DefaultInfo].default_runfiles
        if rf != None:
            files.append(rf.files)
    return [
        DefaultInfo(
            files = depset(transitive = files),
        ),
    ]

_runfiles_group = rule(
    implementation = _runfiles_group_impl,
    attrs = {
        "srcs": attr.label_list(),
    },
)

def codeql_pkg_runfiles(*, name, exes, **kwargs):
    """
    Create a `codeql_pkg_files` with all runfiles from files in `exes`, flattened together.
    """
    internal = _make_internal(name)
    _runfiles_group(
        name = internal("runfiles"),
        srcs = exes,
        visibility = ["//visibility:private"],
    )
    codeql_pkg_files(
        name = name,
        exes = [internal("runfiles")],
        **kwargs
    )
