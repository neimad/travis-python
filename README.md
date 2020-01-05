travis-python
=============
Helps to install Python to Travis CI machines in Linux, macOS and Windows.

[![Build Status][ci-badge]][ci]
[![License][license-badge]][license]

_travis-python_ is just a Bash script providing a helper function:

```bash
install_python $LOCATION $SPECIFIER
```

The specified Python version, if found, will be installed at the specified
`location`.

The `specifier` is similar to [the `python` key available in the Travis CI configuration file][travis-python-versions]:

 - if a full version is specified (e.g. `2.7.1`), that version is installed, if
   available,
 - if the patch version is ignored (e.g. `3.7`) the latest matching stable
   version available is installed, if any,
 - if only the major version is specified (e.g. `3`) the latest matching
   stable version available is installed, if any,

> :warning: Version constraints (e.g. `~`, `^` or `*`) are NOT supported.

Usage
-----

To be able to use _travis-python_, the Travis machine needs to be configured
to be able to run in the three operating systems.

First, use a `shell` environment as it is the only minimal environment available
in the three OS:

```yaml
language: shell
```

Then, specify the required operating systems:

```yaml
os:
  - linux
  - osx
  - windows
```

Finally, load the _travis-python_ script during the `pre-install` phase:

```yaml
pre-install:
  - source <(curl -sSL https://git.io/JeaZo)
  - install_python $LOCATION $VERSION
```

### Jobs for multiple Python versions

You can run jobs for multiple Python versions by using an environment variable
within the job matrix:

```yaml
env:
  - PYTHON="3.7"
  - PYTHON="3.6"

pre-install:
  - install_python $LOCATION $PYTHON
```

### Caching data

To speed up your jobs, you can cache the Python environment:

```yaml
pre-install:
  - install_python $HOME/Python $PYTHON

cache:
  directories:
    - $HOME/Python
```

### Minimal recommended configuration

```yaml
language: shell

os:
  - linux
  - osx
  - windows

osx_image: xcode11

env:
  - PYTHON="3.8"
  - PYTHON="3.7"
  - PYTHON="3.6"
  - PYTHON="2"

pre-install:
  - source <(curl -sSL https://git.io/JeaZo)
  - install_python $HOME/Python $PYTHON

install: ...

script: ...

cache:
  directories:
    - $HOME/Python
```

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

 - use Pyenv to install Python environment on Linux and macOS,
 - use Chocolatey to install Python environment on Windows,
 - use a pure Bash script because it is the shell commonly available on all
   operating systems available on Travis CI,
 - use a Bash 3.2 compatible script because it is the one available on macOS.

Running tests
-------------

Use [shellspec][shellspec] to run unit tests:

```bash
shellspec
```

Contributing
------------

If you're facing an issue using `travis-python`, please look at
[the existing tickets][issues]. Then you may open a new one.

You may also make a [pull request][pull-requests] to help improve it.

License
-------

`travis-python` is licensed under the [GNU GPL 3][GPL] or later.

[ci]: https://travis-ci.org/neimad/travis-python
[ci-badge]: https://img.shields.io/travis/neimad/travis-python?style=flat-square
[license]: https://github.com/neimad/travis-python/blob/master/LICENSE.md
[license-badge]: https://img.shields.io/github/license/neimad/travis-python?style=flat-square
[repository]: https://github.com/neimad/travis-python
[issues]: https://github.com/neimad/travis-python/issues
[pull-requests]: https://github.com/neimad/travis-python/pulls
[GPL]: https://www.gnu.org/licenses/gpl.html
[travis-python-versions]: https://docs.travis-ci.com/user/languages/python/#specifying-python-versions
[shellspec]: https://shellspec.info
