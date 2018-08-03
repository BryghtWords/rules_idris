
def _idris_binary_impl(ctx):
    args =  [f.path for f in ctx.files.srcs] + ["-o", ctx.outputs.bin.path]

    # Action to call the script.
    ctx.actions.run_shell(
        inputs = ctx.files.srcs + [ctx.executable._idris],
        outputs = [ctx.outputs.bin],
        arguments = args,
        progress_message = "progress",
        tools = [ctx.executable._idris],
        command = "HOME=`pwd` %s \"$@\"" % ctx.executable._idris.path,
    )
    return [DefaultInfo(executable = ctx.outputs.bin)]

idris_binary = rule(
  implementation = _idris_binary_impl,
  outputs = { "bin": "bin/%{name}", },
  attrs = {
    "srcs": attr.label_list(
        allow_files = True,
        mandatory = True,),
    "deps": attr.label_list(allow_files = True),
    "_idris": attr.label(
        executable = True,
        cfg = "host",
        allow_files = True,
        default = Label("@idris//:bin/idris"),
    )
  },
  executable = True,
)
