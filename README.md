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

**PREREQUISITES:** [Having nix installed locally](https://nixos.org/nix/download.html)

This approach allows nix to retrieve idris for you. In fact, in the future this will allow per project configuration of the idris version to use.

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

**PREREQUISITES:** [Having idris installed locally](https://www.idris-lang.org/download/)

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

Add the following into the `BUILD` file for your executable:

```python
load("@rules_idris//idris:rules_idris.bzl", "idris_binary")

idris_binary (
    name = "name_of_the_binary",
)
```

It will automatically pick up all the `idr` files from the same folder than the `BUILD` file

### Create an idris module

Add the following into the `BUILD` file for your executable:

```python
load("@rules_idris//idris:rules_idris.bzl", "idris_library")

idris_library (
    name = "name_of_the_library",
    visibility = ["//visibility:public"],
)
```

It will automatically pick up all the `idr` files from the same folder than the `BUILD` file

### Test an idris module

If we want to test a library, like the one [from the previous section](#create-an-idris-module), we should tweak it's `BUILD` file to look like this:

```python
load("@rules_idris//idris:rules_idris.bzl", "idris_library", "idris_test")

idris_library (
    name = "library_example",
    visibility = ["//visibility:public"],
)

idris_test (
    name = "test_example",
    deps = ["library_example"],
)
```

The `idris_test` rule is going to pick up all the `idr` files from the `test` subfolder from where the `BUILD` file is located. Each `idr` in the test should have a test method with this signature:

```idris
export
test : IO ()
```

And the implementation of that method should do nothing if all the tests pass, or exit with a non zero value if the test fails. This will allow for easy integration with external testing libraries.

Tutorials
---------

### Create a simple hello world
TODO


