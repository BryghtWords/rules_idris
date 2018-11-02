load("@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl", "nixpkgs_git_repository", "nixpkgs_package")

load(":private/idris_loader_impl.bzl", "loadScala")

def loadIdris(localIdrisInstallation=None):
  loadScala()
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
