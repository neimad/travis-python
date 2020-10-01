# install_python()

```bash
install_python [-p] <location> <specifier>
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

By default, only stable versions are installed. If the `-p` flag is specified,
pre-release versions are considered.
