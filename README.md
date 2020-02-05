travis-python
=============
Helps to install Python to Travis CI machines in Linux, macOS and Windows.

![Supported Python versions][python-versions-badge]
![Supported Operating Systems][os-badge]
[![Build Status][ci-badge]][ci]
[![License][license-badge]][license]

> :warning: This project is under development and not stable at all! Please
> wait for the first stable version before using it in production.

_travis-python_ is just a Bash script providing a helper function:

```bash
install_python <location> <specifier>
```

The specified Python version, if found, will be installed at the specified
`location`.

The `specifier` is similar to [the `python` key available in the Travis CI configuration file][travis-python-versions]:

 - if a full version is specified (e.g. `2.7.1`), that version is installed, if
   available,
 - if the patch version is ignored (e.g. `3.7`) the latest matching stable
   version available is installed, if any,
 - if only the major version is specified (e.g. `3`) the latest matching
   stable version available is installed, if any.

> :warning: Version constraints (e.g. `~`, `^` or `*`) are NOT supported.

Usage
-----

To be able to use _travis-python_, the Travis machine needs to be configured
to be able to run in the three operating systems.

The easiest way to do it is to [import the shared configuration snippet]:

```yaml
import:
  - source: neimad/travis-python:dev.yml
    mode: deep_merge_prepend
```

**The imported configuration needs to be prepended** and **a deep merge is
required** to be able to use the installed Python distribution in the
`before_install` and subsequent phases.

Read [the configuration documentation] to understand how it works.

Then, specify the wanted Python version using the `PYTHON` environment
variable:

```yaml
import:
  - source: neimad/travis-python:dev.yml
    mode: deep_merge_prepend

env:
  - PYTHON=3.8
  - PYTHON=3.7
  - PYTHON=2
```
By default, it will generate a build matrix using the three operating systems
available on Travis CI (Linux, macOS and Windows).

The Python distribution is installed during the `before_install` phase and
available using the `python` program name (whether it is Python 2 or 3).

Behind the scene
----------------

To provide a similar Python environment for the three operating systems
available on Travis CI, we have to deal with many issues:

 - the Python language is only officialy supported on Linux,
 - Python environments use different executables names depending on the OS
   pointing alternatively to Python 3 or Python 2 executables,
 - choosing the Python version is challenging: it depends on the OS version and
   installing a custom Python distribution depends on the packages management
   system.

To solve those problems, some directions have been taken:

 - use python-build from Pyenv to install Python environment on Linux and macOS,
 - use Chocolatey to install Python environment on Windows,
 - use a pure Bash script because it is the shell commonly available on all
   operating systems available on Travis CI,
 - use a Bash 3.2 compatible script because it is the one available on macOS.

Running tests
-------------

Use [Shellspec] to run unit tests:

```console
shellspec
```

Development
-----------

The following dependencies are required:
  - [ShellCheck] to lint shell scripts,
  - [Shellspec] to run units tests,
  - [Bash] to run the script.

Install the pre-commit hook within your repository:

```console
poetry run pre-commit install
```

Contributing
------------

If you're facing an issue using `travis-python`, please [look at the existing
tickets]. Then you may open a new one.

You may also [make a pull request] to help improve it.

Changelog
---------

See [the changelog] to see what changes have been made and what you can expect
in the next release.

License
-------

`travis-python` is licensed under the [GNU GPL 3 or later][license].

[python-versions-badge]: https://img.shields.io/badge/python-2.7%20|%203.6%20|%203.7%20|%203.8-blue?style=flat-square
[os-badge]: https://img.shields.io/badge/OS-Linux%20|%20macOS%20|%20Windows-blueviolet?style=flat-square
[ci-badge]: https://img.shields.io/travis/neimad/travis-python?style=flat-square
[license-badge]: https://img.shields.io/github/license/neimad/travis-python?style=flat-square

[license]: LICENSE.md
[the changelog]: CHANGELOG.md
[the configuration documentation]: doc/Travis_Configuration.md
[look at the existing tickets]: https://github.com/neimad/travis-python/issues
[make a pull request]: https://github.com/neimad/travis-python/pulls
[ci]: https://travis-ci.com/neimad/travis-python

[travis-python-versions]: https://docs.travis-ci.com/user/languages/python/#specifying-python-versions
[import the shared configuration snippet]: https://docs.travis-ci.com/user/build-config-imports/
[Shellspec]: https://shellspec.info/
[ShellCheck]: https://www.shellcheck.net/
[Bash]: https://www.gnu.org/software/bash/
