[Idris](https://www.idris-lang.org/) rules for [Bazel](https://bazel.build/)
=====================

Getting Started
--------------

Two quick options to get you started:

  * If you are already familiar with [bazel](https://bazel.build/), you can continue with the [add rules_idris to a bazel project](#add-rules_idris-to-a-bazel-project) section

  * Otherwise head to the [create a simple hello world](#create-a-simple-hello-world) tutorial

Add rules_idris to a bazel project
----------------------------------

If you have [the nix package manager](https://nixos.org/nix/) installed locally, you can [use it](#install-idris_rules-using-nix) and bazel is going to get idris for you.

Otherwise, you can [use a local installation of idris](#install-idris_rules-using-a-local-idris-installation)

Afterwards you might want to [add an executable](#create-an-idris-module), [a module](#create-an-idris-module) or [a test](#test-an-idris-module)

### Install idris_rules using nix

This approach allows nix to retrieve idris for you. In fact, in the future this will allow to configure which version of idris you want to use.

Add the following to your `WORKSPACE` file:

```python
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
git_repository(
    name = "rules_idris",
    remote = "https://github.com/BryghtWords/rules_idris.git",
    tag = "v0.1"
)

load("@rules_idris//idris:idris_repos.bzl", "loadIdrisRepositories")

loadIdrisRepositories()

load("@rules_idris//idris:idris_loader.bzl", "loadIdris")

loadIdris()
```

### Install idris_rules using a local idris installation

With this approach, you need a local installation of idris, and to tell bazel where to find it.

1. Add the following snippet into your `WORKSPACE` file

```python
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
git_repository(
    name = "rules_idris",
    remote = "https://github.com/BryghtWords/rules_idris.git",
    tag = "v0.1"
)

load("@rules_idris//idris:idris_repos.bzl", "loadIdrisPackagerRepositories")

loadIdrisPackagerRepositories()

load("@rules_idris//idris:local_idris_loader.bzl", "loadIdris")

loadIdris("/path/to/idris/installation") # That is, wichever path that contains 'bin/idris'
```

2. Locate where you have idris installed (that is, the folder that contains `bin/idris`) 
3. On the text you have just added, replace `/path/to/idris/installation` with the correct path

### Create an idris executable
TODO

### Create an idris module
TODO

### Test an idris module
TODO

Tutorials
---------

### Create a simple hello world
TODO


