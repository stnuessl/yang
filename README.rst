==================================
yang - yet another ninja generator
==================================

.. image:: https://github.com/stnuessl/yang/actions/workflows/build.yaml/badge.svg
   :alt: Build
   :target: https://github.com/stnuessl/yang/actions

.. image:: https://img.shields.io/badge/License-MIT-blue.svg
   :alt: License: GPL v2
   :target: https://mit-license.org/

A `ninja <https://ninja-build.org/>`_ build file generator for simple C projects.

.. contents::

Motivation
==========

In embedded projects it is quite common that a single binary must be built
using different toolchains. A host compiler might be used for development,
analysis, or testing, while a cross-compiler is required to produce the final
firmware. Most common build systems cannot handle this scenario in a single
pass. They need to be reconfigured or reinvoked for each toolchain, which is
inefficient and cumbersome. In practice this usually leads to an additional
layer of custom scripts to glue everything together.

This approach has a major downside: it breaks integration with modern code
editors and IDEs. A proper
`compilation database <https://clang.llvm.org/docs/JSONCompilationDatabase.html>`_
that can be consumed by a language server is key for IDE support, but embedded
toolchains rarely provide these conveniences. As a result, developers lose
productivity because their editor lacks accurate code completion, diagnostics,
and navigation.

**yang** addresses this problem by detaching the build process for the embedded
target from the original build system. The original build system is never
configured for cross-compilation — instead, executables and libraries are defined
as if they were built for the host. This enables smooth IDE integration and the
creation of a valid compilation database. At the same time, **yang** is fed
with the information it needs — toolchain paths, compiler and linker options, and
so on—to generate a *ninja* build that actually produces the embedded binary.

This way, the existing build system provides the integration needed for a
productive development environment, while **yang** and *ninja* handle the heavy
lifting of building the real target under the hood.

Advantages
==========

- One build system configuration to handle all use cases: development, analysis,
  testing and build the embedded target.

Disadvantages
=============

- Nested ninja build
- Hard to analyze issues within the build
- Plumbing code required for integration into project.


Installation
============

Dependencies
------------

The following dependencies are required for using **yang**:

- `ninja <https://ninja-build.org>`_
- `python 3.13+ <https://www.python.org>`_
- `jinja2 <https://jinja.palletsprojects.com>`_

To be able to execute the `advanced example <#advanced-example>`_, retrieve and
install the dependencies from this
`Dockerfile <docker/archlinux-setup/Dockerfile>`_.

**Installation steps**

Clone the repository and install the dependencies:

.. code-block:: sh

   git clone https://github.com/stnuessl/yang.git
   cd yang
   python run src/yang/__main__.py --help


Usage
=====

This section provides both a basic and an advanced usage example. The basic
example demonstrates a standalone invocation of **yang**, while the advanced
example shows how to integrate it into a CMake-based project.

Basic Example
-------------

At its core, **yang** generates a `build.ninja` file from a *jinja2* template
that contains generic compile and link rules. To maximize flexibility, this
is done in multiple stages.

It's best to look at a trivial example, although it might not so useful in
real world projects. `Here <example/scripts/build.sh>`_ is a simple shell script
which uses **yang** to generate a ninja build file to build the project in the
*example* directory. The *jinja2* build template file used by the example
looks like `this <example/template/build.j2>`_.


Advanced Example
----------------

.. _readme_advanced_example:

For a more complete integration, see the `example <example>`_ directory.
It demonstrates how to embed **yang** into a `CMake <https://cmake.org/>`_
project, using custom properties to control the compiler, linker, and toolchain
options.

To run the example, simply execute:

.. code-block:: sh

   make

from the project root.

