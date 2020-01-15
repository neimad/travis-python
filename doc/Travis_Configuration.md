# Travis CI Configuration

This document helps you understand how the Travis CI machine is configured to
use `travis-python` when you import one of ours shared configuration snippets.

It is usefull if you want to use a custom configuration without importing
snippet.

## CI Environment

The `shell` environment is used because it is the only minimal environment
available in the three OSes:

```yaml
language: shell
```

## Operating system

As `travis-python` is intented to be used to test Python software on Linux,
macOS and Windows; all three are specified:

```yaml
os:
  - linux
  - osx
  - windows
```

## Script loading

The `travis-python` script is loaded during the `pre-install` phase.

It need to be sourced in order to modify environment variables (like `PATH`) in
the current shell. But as macOS machines use Bash 3.2, sourcing from `stdin` is
not supported:

```yaml
pre-install:
    - source <(curl -sSL $url) # not supported on Bash 3.2
```

So, the script is downloaded using `wget` then sourced:

```yaml
pre-install:
  - wget https://raw.githubusercontent.com/neimad/travis-python/master/travis-python.bash
  - source travis-python.bash
```

## Python installation

Finally, the Python distribution can be installed in the `$HOME/python`
directory:

```yaml
pre-install:
    - ...
    - install_python $HOME/python $PYTHON
```

The Python distribution version to install is specified using the `PYTHON`
environment variable.
