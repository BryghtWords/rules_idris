![Idris Rules Logo](logo/IdrisRulesLogoText.png "Idris Rules")

[Idris](https://www.idris-lang.org/) rules for [Bazel](https://bazel.build/)
=====================

[![Build Status](https://travis-ci.org/BryghtWords/rules_idris.svg?branch=master)](https://travis-ci.org/BryghtWords/rules_idris)

  > The 13th episode of *[Ivor the Engine](https://en.wikipedia.org/wiki/Ivor_the_Engine#Episodes)* (in colour) is titled *Unidentified Objects*. Let's hope our codebase don't have any of those.
  > 
  > *Idris the Dragon*


Table of Contents
-----------------

   * [<a href="https://www.idris-lang.org/" rel="nofollow">Idris</a> rules for <a href="https://bazel.build/" rel="nofollow">Bazel</a>](#idris-rules-for-bazel)
      * [Table of Contents](#table-of-contents)
      * [Overview](#overview)
      * [Getting Started](#getting-started)
      * [Add rules_idris to a bazel project](#add-rules_idris-to-a-bazel-project)
         * [Install idris_rules using nix](#install-idris_rules-using-nix)
         * [Install idris_rules using a local idris installation](#install-idris_rules-using-a-local-idris-installation)
         * [Create an idris executable](#create-an-idris-executable)
         * [Create an idris module](#create-an-idris-module)
         * [Test an idris module](#test-an-idris-module)
      * [Tutorials](#tutorials)
         * [Create a simple hello world](#create-a-simple-hello-world)
            * [Concerning Bazel](#concerning-bazel)
            * [1. Create the project](#1-create-the-project)
            * [2. Setup rules_idris](#2-setup-rules_idris)
            * [3. Add the executable module](#3-add-the-executable-module)
            * [Let's try it](#lets-try-it)
         * [Create a simple module](#create-a-simple-module)
            * [1. Create a package and module](#1-create-a-package-and-module)
            * [2. Implement some functionality for the module](#2-implement-some-functionality-for-the-module)
            * [3. Make our binary use the module](#3-make-our-binary-use-the-module)
         * [Write a simple idris test](#write-a-simple-idris-test)
            * [1. Write the test](#1-write-the-test)
            * [2. Create the test module](#2-create-the-test-module)
            * [Let's try it](#lets-try-it-1)
      * [Known Issues](#known-issues)
      * [Roadmap](#roadmap)

ToC created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

Overview
--------

**Idris rules** adds Idris support for Bazel. Bazel is a powerful and well maintained build tool with [a lot of interesting characteristics](https://bazel.build/#why-bazel). Combining Bazel and Idris rules, we get an idris build tool that:

 * Can build different types of components (executables, libraries and tests)
 * Make components easy to integrate between them
 * It's easy to configure (for example, there is no need to specify the list of files/modules of your component by hand)
 * Supports **external dependencies**. External dependencies only need to be Idris+Bazel projects hosted somewhere (like github, bitbucket, gitlab, ...). This means that, to support external dependencies there is no need to create and maintain some kind of central repository infrastructure. And it's easy for library developers to publish their work.

And there are [more features to come](#roadmap)

Getting Started
--------------

**PREREQUISITES:** [Having bazel installed locally](https://docs.bazel.build/versions/master/install.html)

Two quick options to get you started:

  * If you are already familiar with [bazel](https://bazel.build/), you can continue with the [add rules_idris to a bazel project](#add-rules_idris-to-a-bazel-project) section

  * Otherwise head to the [create a simple hello world](#create-a-simple-hello-world) tutorial

Add rules_idris to a bazel project
----------------------------------

To get started with rules_idris, you only need to initialize them on your `WORKSPACE` file and you will be ready to go. For that you have two options:

 * If you have [the nix package manager](https://nixos.org/nix/) installed locally, you can [use it](#install-idris_rules-using-nix) and bazel is going to get idris for you.

 * Otherwise, you can [use a local installation of idris](#install-idris_rules-using-a-local-idris-installation)

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
    tag = "v0.2"
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
    tag = "v0.2"
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

Add the following into the `BUILD` file for your module:

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
test : IO Bool -- This should be true if the test or tests in this suite are successful
```

The implementation of this method should return true if all the tests of this suite pass, or false otherwise. This will allow for easy integration with external testing libraries.

Tutorials
---------

### Create a simple hello world

Creating a basic project for a simple executable, is a simple three step process:

1. Create the project
2. Setup idris rules
3. Add the executable module

#### Concerning Bazel

Bazel projects (also called [workspaces](https://docs.bazel.build/versions/master/build-ref.html#workspace)) are collections of [targets](https://docs.bazel.build/versions/master/build-ref.html#targets). For simplicity, I'm going to say that targets are things that can be built (this is not really true, but will help understand how bazel works).

In turn, this targets are organized into [packages](https://docs.bazel.build/versions/master/build-ref.html#packages). All targets must belong to a package.

You can think of a workspace as a folder that contains a file named `WORKSPACE`. Everything in that folder and subfolders belong to the workspace. Likewise, the `WORKSPACE` file must live in the root folder of your project.

You can think of a package as a folder in the workspace that contains a file named `BUILD`. Everything in that folder and subfolders that are not packages themselves (that is, that don't contain a `BUILD` file) belong to the package.

If you look at this example:

```
|____my-package
| |____BUILD
| |____foo.h
| |____src
| | |____bar.cpp
| |____sub
| | |____BUILD
| | |____baz.h
| | |____src
| | | |____qux.cpp
```

`my-package/foo.h` and `my-package/src/bar.cpp` belong to the package `my-package`, where `my-package/sub/baz.h` and `my-package/sub/src/qux.cpp` belong to `sub`

It's also worth noticing that the root folder can be both the workspace and a package. That is, by containing both a `WORKSPACE` file and a `BUILD` file.

The `WORKSPACE` file holds general configuration for the project, things like what external repositories to access or tools to use. The `BUILD` files list the targets for that package.

#### 1. Create the project

A bazel project is just a folder with a `WORKSPACE` file. Here we go:

```bash
mkdir my-project
cd my-project
touch WORKSPACE
```

#### 2. Setup rules_idris

On this step you have to choose:

1. To use the nix package manager (and install it if you don't already have it)

or

2. To use a local installation of idris (and install it if you don't already have it)

After that, you basically need to add content on your `WORKSPACE` file to tell bazel how to get and use rules_idris. It's preatty much a copy-and-paste as explained [in here if you use nix](#install-idris_rules-using-nix) or, otherwise as explained [in here if you use a local installation of idris](#install-idris_rules-using-a-local-idris-installation)

#### 3. Add the executable module

This is where we create our first bit of idris. We will do three things:

1. Create the package
2. Create the idris code
3. Configure the target

So first, as mentioned before, a package is a folder with a `BUILD` file. Starting from the root folder:

```bash
mkdir bin # we can name this folder whatever we want
cd bin
touch BUILD
```

Then we need a bit of idris code. Let's put this code in `bin/Binary.idr`:

```idris
module Main

main : IO ()
main = putStrLn "Hello, world!"
```

And finally, we need to tell bazel about it. Let's add this to the `bin/BUILD` file:

```python

load("@rules_idris//idris:rules_idris.bzl", "idris_binary")

idris_binary (
    name = "binary_example",
)

```

#### Let's try it

And that's it, we can now build it:

```bash
bazel build //bin:binary_example
```

Or run it:

```bash
bazel run //bin:binary_example
```

After running either command, you can find your new file at:

```
bazel-bin/bin/bin/binary_example
```

### Create a simple module

Call it module or library, the distinction is quite difuse in bazel. What we are talking about is a bunch of reusable code that is not, by itself, an executable. For that, all we need is a target that describes how to create this module. And usualy, we put modules on their own packages.

This tutorial follows up from [create a simple hello world](#create-a-simple-hello-world), so from the root folder from the result of that tutorial, we are going to do the following:

1. Create a package and module
2. Implement some functionality for the module
3. Make our binary use the module

#### 1. Create a package and module

We only need a new folder and `BUILD` file:

```bash
mkdir lib
touch lib/BUILD
```

And tell the `BUILD` file about our new module. Write this into the `BUILD` file:

```python
load("@rules_idris//idris:rules_idris.bzl", "idris_library") # This puts the `idris_library` function in scope. It's basically an `import`

# This declares the new library
idris_library (
    name = "salutes", # Named `salutes`
    visibility = ["//visibility:public"], # Accessible from any other bazel target
)
```

#### 2. Implement some functionality for the module

Let's start wit a simple bit of idris code. Create the file `lib/Salute.idr`, and add it's functionality:

```idris
module lib.Salute

export
salute : String
salute = "Hello, library example of idris"
```

#### 3. Make our binary use the module

Two steps, first tell the binary target it can use the new module. Fot that, edit `bin/BUILD` to make it look like this:

```python

load("@rules_idris//idris:rules_idris.bzl", "idris_binary")

idris_binary (
    name = "binary_example",
    deps = ["//lib:salutes"], # This is the line that has been added
)
```

And finally, let's make un application use the library. Edit `bin/Binary.idr`, to use the new function:

```idris

module Main

import lib.Salute

main : IO ()
main = putStrLn salute

```

You can try your new code as explained in [here](#lets-try-it).

### Write a simple idris test

From the point of view of bazel, a test is an executable that once run its exit status id either 0 when everything has gone ok or not 0 if something has gone wrong. Bazel doesn't care for anything else.

For this purpose, idris rules provides `idris_test`. A rule that generates the executable's `main` function for you. And expects a single `test` function on each source file on the test module. This `test` functions must have this signature:

```idris
export
test : IO Bool -- This should be true if the test or tests in this suite are successful
```

Given that, only `idris_library` modules can be tested because the test itself must be an executable and merging two executables is dificult.

So, for this tutorial we are going to start from the result of [create a simple module](#create-a-simple-module).

#### 1. Write the test

Tests live on the `test` subfolder of the module you want to test. Since we are testing the `lib:salutes` module, from the root folder execute:

```bash
mkdir lib/test
touch lib/test/SaluteTest.idr
```

And write a simple test on `lib/test/SaluteTest.idr`:

```idris
module lib.test.LibTest

import lib.Library

export
test : IO Bool
test = pure (salute == "Hello, library example of idris")
```

#### 2. Create the test module

Now, we only need to register the new test module. For that purpose, edit `lib/BUILD` to look like this:

```python

load("@rules_idris//idris:rules_idris.bzl", "idris_library", "idris_test") # CHANGE 1: This now also imports `idris_test`

idris_library (
    name = "salutes",
    visibility = ["//visibility:public"],
)

# CHANGE 2: Add the new test module
idris_test (
    name = "test_salutes",
    deps = ["salutes"], # This tells bazel to link the library we are testing into the executable that is going to run the tests
)

```

#### Let's try it

And that's it, we can now build our testing module:

```bash
bazel build //lib:test_salutes
```

Or run the tests directly:

```bash
bazel test //lib:test_salutes
```

NOTE: By default, bazel logs the result of running the tests but doesn't print them on STDOUT. If you want to see the results of running the test (which since there is no `putStrLn` is going to be empty anyway), you should run this:

```bash
bazel test //lib:test_salutes --test_output=all
```


Known Issues
------------

- Testing of the rules themselves need to be improved. In the examples folder there is a prety big collection of bazel projects using rules_idris, with a different organisation each. And there is a 'test' script that builds and runs each of them in turn ensuring that everything goes well, but proper unit testing would be in order.

Roadmap
-------

 - [x] Improve testing integration
 - [ ] Add support for starting the idris console from bazel
 - [ ] Add support for the IDE mode on bazel projects
 - [ ] Support multiple idris versions
 - [ ] Add javascript and jvm rules
 - [ ] Migrate the [companion IdrisPackager project](https://github.com/BryghtWords/idris_packager) from Scala to Idris
 - [ ] Improve reporting of test results
