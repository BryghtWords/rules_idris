

def _idris_binary_impl(ctx):
    modules_files = [ d.files.to_list()[0] for d in ctx.attr.deps]
    modules = [ mf.path for mf in modules_files]
    args =  [arg
             for m in modules
             for arg in ["--ip", m]] + [f.path for f in ctx.files.srcs] + ["-o", ctx.outputs.bin.path]

    # Action to call the script.
    ctx.actions.run_shell(
        inputs = ctx.files.srcs + [ctx.executable._idris, ctx.executable._idris_packager] + modules_files,
        outputs = [ctx.outputs.bin],
        arguments = args,
        progress_message = "progress",
        tools = [ctx.executable._idris, ctx.executable._idris_packager],
        command = "cd `dirname %s` && pwd && ls -lah && cd - && HOME=`pwd` %s idris %s \"$@\"" % (modules[0], ctx.executable._idris_packager.path, ctx.executable._idris.path),
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
    modules = [_remove_extension(f).replace("/", ".") for f in ctx.files.srcs]

    [
    ctx.actions.write(
      output = ctx.outputs.ipkg,
      content = "package %s\n\nmodules = %s" % (ctx.attr.name, ", ".join(modules))),
    ctx.actions.run_shell(
        inputs = ctx.files.srcs + [ctx.executable._idris, ctx.executable._idris_packager, ctx.outputs.ipkg],
        outputs = [ctx.outputs.ipz],
        arguments = [],
        progress_message = "progress",
        tools = [ctx.executable._idris, ctx.executable._idris_packager],
        command = "cp \"%s\" \"%s.ipkg\" && HOME=`pwd` %s create \"%s\" \"%s.ipkg\" \"%s\"" % (ctx.outputs.ipkg.path, ctx.attr.name, ctx.executable._idris_packager.path, ctx.executable._idris.path, ctx.attr.name, ctx.outputs.ipz.path),
    ),
    ]

idris_library_rule = rule(
  implementation = _idris_library_impl,
  outputs = { "ipz": "ipz/%{name}.ipz",
              "ipkg": "ipkg/%{name}.ipkg"},
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

