#####################################
# PROVIDERS
#####################################

DependingIPZs = provider(fields = ["transitive_ipzs"])
SelfIPZ = provider(fields = ["ipz"])

#####################################
# BINARY
#####################################

def _idris_binary_impl(ctx):
    ipzs_files = get_transitive_ipzs(ctx.attr.deps)
    ipzs = [ mf.path for mf in ipzs_files.to_list()]
    args =  [arg
             for m in ipzs
             for arg in ["--ip", m]] + [f.path for f in ctx.files.srcs] + ["-o", ctx.outputs.bin.path]

    # Action to call the script.
    ctx.actions.run_shell(
        inputs = ctx.files.srcs + [ctx.executable._idris, ctx.executable._idris_packager] + ipzs_files.to_list(),
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

#####################################
# LIBRARY
#####################################

def _idris_library_impl(ctx):
    ipz = ctx.outputs.ipz
    ipkg = ctx.actions.declare_file("%s.ipkg" % ctx.attr.name) 
    wl = len(ctx.label.workspace_root)
    l = 0 if wl == 0 else wl + 1
    ws = "." if wl == 0 else ctx.label.workspace_root
    modules = [_remove_extension(f)[l:].replace("/", ".") for f in ctx.files.srcs]
    ipzs_files = get_transitive_ipzs(ctx.attr.deps)
    ipzs = [ mf.path for mf in ipzs_files.to_list()]
    args = " ".join([arg
             for m in ipzs
             for arg in ["--ip", "$THE_PATH/%s" % m]])
    command = "export THE_PATH=`pwd` && cd \"%s\" && cp \"$THE_PATH/%s\" \"%s.ipkg\" && HOME=`pwd` $THE_PATH/%s create \"$THE_PATH/%s\" \"%s.ipkg\" \"$THE_PATH/%s\" %s " % (ws, ipkg.path, ctx.attr.name, ctx.executable._idris_packager.path, ctx.executable._idris.path, ctx.attr.name, ipz.path, args)
    inputs = ctx.files.srcs + [ctx.executable._idris, ctx.executable._idris_packager, ipkg] + ipzs_files.to_list()

    # Action to call the script.
    ctx.actions.write(
      output = ipkg,
      content = "package %s\n\nmodules = %s" % (ctx.attr.name, ", ".join(modules)))
    ctx.actions.run_shell(
        inputs = inputs,
        outputs = [ipz],
        arguments = [],
        progress_message = ("building library %s" % ctx.attr.name),
        tools = [ctx.executable._idris, ctx.executable._idris_packager],
        command = command,
    )
    return [
      DependingIPZs(transitive_ipzs=ipzs_files),
      DefaultInfo(files = depset([ipz], transitive=[ipzs_files])),
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

#####################################
# TEST
#####################################

#def _idris_test_impl(ctx):
#    ipkg = ctx.actions.declare_file("%s_test.ipkg" % ctx.attr.name) 
#    test_result = ctx.actions.declare_file("%s.test_result" % ctx.attr.name) 
#    wl = len(ctx.label.workspace_root)
#    l = 0 if wl == 0 else wl + 1
#    ws = "." if wl == 0 else ctx.label.workspace_root
#    modules = [_remove_extension(f)[l:].replace("/", ".") for f in ctx.files.srcs]
#    ipzs_files = get_transitive_ipzs(ctx.attr.deps)
#    ipzs = [ mf.path for mf in ipzs_files.to_list()]
#    args = " ".join([arg
#             for m in ipzs
#             for arg in ["--ip", "%s" % m]])
#    args = "%s " % args
#    command = """
#      NEW="{name}_test.ipkg"
#      cp "{ipkg}" "$NEW"
#      ls -l lib/test
#      HOME=`pwd` \
#      "{idrisPackager}" idris "{idris}" --testpkg "$NEW" {args} && \
#      echo success > "{r}"
#    """.format(
#      idris = ctx.executable._idris.path,
#      idrisPackager = ctx.executable._idris_packager.path,
#      ipkg = ipkg.path,
#      ws = ws,
#      r = test_result.path,
#      name = ctx.attr.name,
#      args = args,
#    )
#    command2 = """
#     cat "{r}"
#    """.format(
#      r = test_result.short_path,
#    )
#    inputs = ctx.files.srcs + [ctx.executable._idris, ctx.executable._idris_packager, ipkg] + ipzs_files.to_list()
#
#    # Action to call the script.
#    ctx.actions.write(
#      output = ipkg,
#      content = "package %s\n\nmodules = %s\ntests = %s" % (ctx.attr.name, ", ".join(modules), ", ".join([("%s.test" % m) for m in modules])))
#    ctx.actions.run_shell(
#        outputs = [test_result],
#        inputs = inputs,
#        arguments = [],
#        progress_message = ("testing library %s" % ctx.attr.name),
#        tools = [ctx.executable._idris, ctx.executable._idris_packager],
#        command = command,
#    )
#    ctx.actions.write(
#      output = ctx.outputs.executable,
#      content = command2,
#    )
#    runfiles = ctx.runfiles(files = [test_result])
#    return [DefaultInfo(runfiles = runfiles)]

def _idris_test_impl(ctx):
    wl = len(ctx.label.workspace_root)
    l = 0 if wl == 0 else wl + 1
    modules = [_remove_extension(f)[l:].replace("/", ".") for f in ctx.files.srcs]
    main = """
module Main

import System
{imports}

__exists : (a -> Bool) -> List a -> Bool
__exists p l = isJust (find p l)

__forall : (a -> Bool) -> List a -> Bool
__forall p l = not (__exists (\i => not (p i)) l)

__finaliseTestRunning : List Bool -> IO ()
__finaliseTestRunning l = if __forall id l
                            then putStrLn "All tests PASSED"
                            else do putStrLn "Some tests FAILED"
                                    exit 1

__run : IO (List Bool)
__run = sequence [{tests}]

main : IO ()
main = __run >>= __finaliseTestRunning

    """.format(
      imports = "\n".join([("import %s" % m) for m in modules]),
      tests = ", ".join([("%s.test" % m) for m in modules]),
    )
    mainModule = ctx.actions.declare_file("__main_module.idr") 
    ctx.actions.write(output = mainModule, content = main)
    ipzs_files = get_transitive_ipzs(ctx.attr.deps)
    ipzs = [ mf.path for mf in ipzs_files.to_list()]
    sources = ctx.files.srcs + [mainModule]
    args =  [arg
             for m in ipzs
             for arg in ["--ip", m]] + [f.path for f in sources] + ["-o", ctx.outputs.test.path]

    # Action to call the script.
    ctx.actions.run_shell(
        inputs = sources + [ctx.executable._idris, ctx.executable._idris_packager] + ipzs_files.to_list(),
        outputs = [ctx.outputs.test],
        arguments = args,
        progress_message = "progress",
        tools = [ctx.executable._idris, ctx.executable._idris_packager],
        command = "HOME=`pwd` %s idris %s \"$@\"" % (ctx.executable._idris_packager.path, ctx.executable._idris.path),
    )
    return [DefaultInfo(executable = ctx.outputs.test)]

idris_rule_test = rule(
  implementation = _idris_test_impl,
  outputs = { "test": "%{name}_runner", },
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
  test = True,
)

def idris_test(name, srcs=None, deps=[], visibility=None):
  idris_rule_test(
    name = name,
    deps = deps,
    srcs = native.glob(["test/*.idr"]) if srcs == None else srcs,
    visibility = visibility,
  )

#####################################
# HELPERS
#####################################


def _remove_extension(p):
    b = p.basename
    last_dot_in_basename = b.rfind(".")

    # If there is no dot or the only dot in the basename is at the front, then
    # there is no extension.
    if last_dot_in_basename <= 0:
        return (p.path, "")

    dot_distance_from_end = len(b) - last_dot_in_basename
    return p.path[:-dot_distance_from_end]

def get_transitive_ipzs(deps):
  ipzs = [dep[SelfIPZ].ipz for dep in deps]
  return depset(
    ipzs,
    transitive = [dep[DependingIPZs].transitive_ipzs for dep in deps])
