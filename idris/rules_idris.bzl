# A provider with one field, transitive_deps
DependingIPZs = provider(fields = ["transitive_ipzs"])
SelfIPZ = provider(fields = ["ipz"])

def get_transitive_ipzs(deps):
  ipzs = [dep[SelfIPZ].ipz for dep in deps]
  return depset(
    ipzs,
    transitive = [dep[DependingIPZs].transitive_ipzs for dep in deps])

def _idris_binary_impl(ctx):
    ipzs_files = get_transitive_ipzs(ctx.attr.deps)
    ipzs = [ mf.path for mf in ipzs_files.to_list()]
    args =  [arg
             for m in ipzs
             for arg in ["--ip", m]] + [f.path for f in ctx.files.srcs] + ["-o", ctx.outputs.bin.path]
    print (str(ipzs))

    # Action to call the script.
    ctx.actions.run_shell(
        inputs = ctx.files.srcs + [ctx.executable._idris, ctx.executable._idris_packager] + ipzs_files.to_list(),
        outputs = [ctx.outputs.bin],
        arguments = args,
        progress_message = "progress",
        tools = [ctx.executable._idris, ctx.executable._idris_packager],
        command = "HOME=`pwd` %s idris %s \"$@\"" % (ctx.executable._idris_packager.path, ctx.executable._idris.path),
        #command = "echo '%s'" % ("\n".join(args)),
    )
    return [DefaultInfo(executable = ctx.outputs.bin)]

idris_binary_rule = rule(
  implementation = _idris_binary_impl,
  outputs = { "bin": "bin/%{name}", },
  attrs = {
    "srcs": attr.label_list(
        allow_files = True,
        mandatory = True,),
    "deps": attr.label_list(),
    "_idris": attr.label(
        executable = True,
        cfg = "host",
        allow_files = True,
        default = Label("@idris//:bin/idris"),),
    "_idris_packager": attr.label(
        executable = True,
        cfg = "host",
        allow_files = True,
        default = Label("@idris_packager//ip:idrisPackager"),),
  },
  executable = True,
)

def idris_binary(name, srcs=None, deps=[]):
  idris_binary_rule(
    name = name,
    deps = deps,
    srcs = native.glob(["*.idr"]) if srcs == None else srcs,
  )

# ###################################################################################

def _remove_extension(p):
    b = p.basename
    last_dot_in_basename = b.rfind(".")

    # If there is no dot or the only dot in the basename is at the front, then
    # there is no extension.
    if last_dot_in_basename <= 0:
        return (p.path, "")

    dot_distance_from_end = len(b) - last_dot_in_basename
    return p.path[:-dot_distance_from_end]

def _idris_library_impl(ctx):
    ipz = ctx.outputs.ipz
    ipkg = ctx.actions.declare_file("%s.ipkg" % ctx.attr.name)
    wl = len(ctx.label.workspace_root)
    l = 0 if wl == 0 else wl + 1
    ws = "." if wl == 0 else ctx.label.workspace_root
    modules = [_remove_extension(f)[l:].replace("/", ".") for f in ctx.files.srcs]
    ipzs_files = get_transitive_ipzs(ctx.attr.deps)
    ipzs = [ mf.path for mf in ipzs_files.to_list()]
    args = [arg
             for m in ipzs
             for arg in ["--ip", m]]
    print("LABEL!!!!\n\n\n%s\n\n" % ctx.label.workspace_root)

    # Action to call the script.
    ctx.actions.write(
      output = ipkg,
      content = "package %s\n\nmodules = %s" % (ctx.attr.name, ", ".join(modules)))
    ctx.actions.run_shell(
        inputs = ctx.files.srcs + [ctx.executable._idris, ctx.executable._idris_packager, ipkg] + ipzs_files.to_list(),
        outputs = [ipz],
        arguments = args,
        progress_message = "progress",
        tools = [ctx.executable._idris, ctx.executable._idris_packager],
        command = "export THE_PATH=`pwd` && cd \"%s\" && cp \"$THE_PATH/%s\" \"%s.ipkg\" && HOME=`pwd` $THE_PATH/%s create \"$THE_PATH/%s\" \"%s.ipkg\" \"$THE_PATH/%s\" \"$@\" " % (ws, ipkg.path, ctx.attr.name, ctx.executable._idris_packager.path, ctx.executable._idris.path, ctx.attr.name, ipz.path),
        #command = "echo '%s'" % ("\n".join(args)),
    )
    return [
      DependingIPZs(transitive_ipzs=ipzs_files),
      DefaultInfo(files = ipzs_files),
      SelfIPZ(ipz = ipz),
    ]

idris_library_rule = rule(
  implementation = _idris_library_impl,
  outputs = { "ipz": "%{name}.ipz" },
  attrs = {
    "srcs": attr.label_list(
        allow_files = True,
        mandatory = True,),
    "deps": attr.label_list(allow_files = True),
    "_idris": attr.label(
        executable = True,
        cfg = "host",
        allow_files = True,
        default = Label("@idris//:bin/idris"),),
    "_idris_packager": attr.label(
        executable = True,
        cfg = "host",
        allow_files = True,
        default = Label("@idris_packager//ip:idrisPackager"),),
  },
  executable = False,
)

def idris_library(name, srcs=None, deps=[], visibility=None):
  idris_library_rule(
    name = name,
    deps = deps,
    srcs = native.glob(["*.idr"]) if srcs == None else srcs,
    visibility = visibility,
  )

