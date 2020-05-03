travis-python
=============
Helps to install Python to Travis CI machines on Linux, macOS and Windows.

![Supported Python versions][python-versions-badge]
![Supported Operating Systems][os-badge]
[![Build Status][ci-badge]][ci]
[![Coverage Status][cov-badge]][coverage]
[![License][license-badge]][license]

Usage
-----

You need to source the provided Bash script and call the [install_python()]
function.

Or just use the shared configuration snippet. The easiest way to do it is to
[import the shared configuration snippet]:

```yaml
import:
  - source: neimad/travis-python:stable.yml
    mode: deep_merge_prepend
```

> :warning: **The imported configuration needs to be prepended** and **a deep merge is
> required** to be able to use the installed Python distribution in the
> `before_install` and subsequent phases.

Read [the configuration documentation] to understand how it works.

Then, specify the operating systems as usual:

```yaml
import:
  - source: neimad/travis-python:stable.yml
    mode: deep_merge_prepend

os:
  - linux
  - osx
  - windows
```

Finally, specify the wanted Python version using the `PYTHON` environment
variable:

```yaml
import:
  - source: neimad/travis-python:stable.yml
    mode: deep_merge_prepend

os:
  - linux
  - osx
  - windows

env:
  - PYTHON=3.8
  - PYTHON=3.7
  - PYTHON=2
```

The Python distribution is installed during the `before_install` phase and
available using the `python` program name (whether it is Python 2 or 3).

Documentation
-------------

[Some documentation] is available.

Why and how ?
-------------

To provide a similar Python environment for the three operating systems
available on Travis CI, we have to deal with many issues:

 - the Python language is only officialy supported on Linux Travis CI machines,
 - Python environments use different executables names depending on the OS
   pointing alternatively to Python 3 or Python 2 executables,
 - fetching a specific Python version is challenging: it depends on the OS
   version and installing a custom Python distribution depends on the packages
   management system.

To solve those problems, some directions have been taken:

 - use python-build from Pyenv to install Python environment on Linux and macOS,
 - use Chocolatey to install Python environment on Windows,
 - use a Bash script because it is the shell commonly available on all operating
   systems available on Travis CI,
 - use a Bash 3.2 compatible script because it is the one available on macOS,
 - use pure Bash functions because external program may differ in behavior
   depending on the operating system type and version.

Development
-----------

The following dependencies are required:
  - [ShellCheck] to lint shell scripts,
  - [Shellspec] to run units tests,
  - [Bash] to run the script,
  - [Pre-commit] to check the changes before committing.

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
[ci-badge]: https://img.shields.io/travis/neimad/travis-python/master?style=flat-square
[cov-badge]: https://img.shields.io/coveralls/github/neimad/travis-python?style=flat-square
[license-badge]: https://img.shields.io/github/license/neimad/travis-python?style=flat-square

[license]: LICENSE.md
[the changelog]: CHANGELOG.md
[the configuration documentation]: doc/Travis_Configuration.md
[install_python()]: doc/install_python.md
[some documentation]: doc/README.md
[look at the existing tickets]: https://github.com/neimad/travis-python/issues
[make a pull request]: https://github.com/neimad/travis-python/pulls
[ci]: https://travis-ci.com/neimad/travis-python
[coverage]: https://coveralls.io/github/neimad/travis-python

[travis-python-versions]: https://docs.travis-ci.com/user/languages/python/#specifying-python-versions
[import the shared configuration snippet]: https://docs.travis-ci.com/user/build-config-imports/
[Shellspec]: https://shellspec.info/
[ShellCheck]: https://www.shellcheck.net/
[Bash]: https://www.gnu.org/software/bash/
[Pre-commit]: https://pre-commit.com/
