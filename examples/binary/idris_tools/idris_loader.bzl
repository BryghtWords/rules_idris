load("@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl", "nixpkgs_git_repository", "nixpkgs_package")
load("@io_bazel_rules_scala//scala:toolchains.bzl", "scala_register_toolchains")
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_repositories")

def loadIdris():
  nixpkgs_git_repository(
      name = "nixpkgs",
      revision = "da53c1248ba3c56d0ee67d8ab1d0849f9453bbb5", # Any tag or commit hash
      sha256 = "" # optional sha to verify package integrity!
  )
  nixpkgs_package(
      name = "idris",
      repository = "@nixpkgs",
      attribute_path = "idris"
  )
  scala_repositories(("2.12.6", {
    "scala_compiler": "3023b07cc02f2b0217b2c04f8e636b396130b3a8544a8dfad498a19c3e57a863",
    "scala_library": "f81d7144f0ce1b8123335b72ba39003c4be2870767aca15dd0888ba3dab65e98",
    "scala_reflect": "ffa70d522fc9f9deec14358aa674e6dd75c9dfa39d4668ef15bb52f002ce99fa"
  }))
  native.register_toolchains("@idris_packager//toolchains:bryght_scala_toolchain")


