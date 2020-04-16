# setup_travis_python()

```bash
setup_travis_python
```

Setup the current environment to allow _travis-python_ to work properly.

On Windows, Chocolatey is downgraded to version `0.10.13` to work around a bug.
See https://github.com/chocolatey/choco/issues/1843.

On Unix platforms, [python-build] is installed from [pyenv repository] to allow
installation of Python distributions.

[python-build]: https://github.com/pyenv/pyenv/tree/master/plugins/python-build
[pyenv repository]: https://github.com/pyenv/pyenv
