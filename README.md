[Idris](https://www.idris-lang.org/) rules for [Bazel](https://bazel.build/)
=====================

Getting Started
--------------

Two quik options to get you started:

  *) If you are already familiar with [bazel](https://bazel.build/), you can head to the [add rules_idris to a bazel project](#add-rules_idris-to-a-bazel-project) section

  *) Otherwise head to the [create a simple hello world](#create-a-simple-hello-world) tutorial

Add rules_idris to a bazel project
----------------------------------

If you have [the nix package manager](https://nixos.org/nix/) installed locally, you can [use it](#foo) and bazel is going to get idris for you.

Otherwise, you can [use a local installation of idris](#foo)

### Install idris_rules using nix

Add the following to your `WORKSPACE` file:

```python
local_repository(
  name = "rules_idris",
  path = "../..",
)

load("@rules_idris//idris:idris_repos.bzl", "loadIdrisRepositories")

loadIdrisRepositories()

load("@rules_idris//idris:idris_loader.bzl", "loadIdris")

loadIdris()
```

### Install idris_rules using a local idris installation

Add the following to your `WORKSPACE` file:

```python
local_repository(
  name = "rules_idris",
  path = "../..",
)

load("@rules_idris//idris:idris_repos.bzl", "loadIdrisPackagerRepositories")

loadIdrisPackagerRepositories()

load("@rules_idris//idris:local_idris_loader.bzl", "loadIdris")

loadIdris("/path/to/idris/installation") # That is, wichever path that contains 'bin/idris'
```

Tutorials
---------

### Create a simple hello world

