

def _idris_binary_impl(ctx):
    args =  [f.path for f in ctx.files.srcs] + ["-o", ctx.outputs.bin.path]

    # Action to call the script.
    ctx.actions.run_shell(
        inputs = ctx.files.srcs + [ctx.executable._idris, ctx.executable._idris_packager],
        outputs = [ctx.outputs.bin],
        arguments = args,
        progress_message = "progress",
        tools = [ctx.executable._idris, ctx.executable._idris_packager],
        command = "HOME=`pwd` %s idris %s \"$@\"" % (ctx.executable._idris_packager.path, ctx.executable._idris.path),
    )
    return [DefaultInfo(executable = ctx.outputs.bin)]

idris_binary_rule = rule(
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
# 
# def _idris_native_library_impl(ctx):
#     args =  [f.path for f in ctx.files.srcs]
# 
#     # Action to call the script.
#     ctx.actions.run_shell(
#         inputs = ctx.files.srcs + [ctx.executable._idris],
#         outputs = ctx.files.srcs + [ctx.files.__touch__],
#         arguments = args,
#         progress_message = "progress",
#         tools = [ctx.executable._idris],
#         command = "HOME=`pwd` %s \"$@\"" % ctx.executable._idris.path,
#     )
# 
# idris_native_library = rule(
#   implementation = _idris_native_library_impl,
#   attrs = {
#     "srcs": attr.label_list(
#         allow_files = True,
#         mandatory = True,),
#     "deps": attr.label_list(allow_files = True),
#     "_idris": attr.label(
#         executable = True,
#         cfg = "host",
#         allow_files = True,
#         default = Label("@idris//:bin/idris"),
#     ),
#     "__touch__": attr.label(default = Label("//{}:__touch__".format(ctx.build_file_path))),
#   },
# )
