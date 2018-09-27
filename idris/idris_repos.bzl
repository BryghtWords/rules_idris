load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def loadIdrisRepositories():
  rules_scala_version="b537bddc58a77318b34165812a0311ef52806318"
  http_archive(
    name = "io_tweag_rules_nixpkgs",
    strip_prefix = "rules_nixpkgs-4575647f3795fee2a8b732f97076a363907f7248",
    urls = ["https://github.com/tweag/rules_nixpkgs/archive/4575647f3795fee2a8b732f97076a363907f7248.tar.gz"],
  )
  http_archive(
    name = "io_bazel_rules_scala",
    url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip"%rules_scala_version,
    type = "zip",
    strip_prefix= "rules_scala-%s" % rules_scala_version
  )
  git_repository(
    name = "idris_packager",
    commit = "df2c7746b97a1fb5755339756d942563c9beadd7",
    remote = "https://github.com/BryghtWords/idris_packager.git"
  )


