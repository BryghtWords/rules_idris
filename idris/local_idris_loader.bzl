
load(":private/idris_loader_impl.bzl", "loadScala")

def loadIdris(localIdrisInstallation=None):
  loadScala()
  native.new_local_repository(
    name = "idris",
    path = localIdrisInstallation, # Change path accordingly.
    build_file_content = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "bin",
    srcs = glob(["bin/*"]),
)
      """
  )
