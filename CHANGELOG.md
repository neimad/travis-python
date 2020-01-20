# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]
### Added
 - Travis CI shared configuration snippet intented to be sourced in user
   configuration (`dev.yml`).
 - pre-commit configuration file.

### Fixed
 - Filtering of daily build (available through Chocolatey) (#9).

## [0.1.2] - 2020-01-13
### Fixed
 - Recommended way of sourcing the `travis-python.bash` script (#2).
 - Unstable versions filtering (#3).

## [0.1.1] - 2020-01-12
### Added
 - Specification which is checked using Shellspec.
 - Unit tests helper to create dummies.
 - This CHANGELOG file.

### Changed
 - Switch from _pyenv_ to _python-build_ for Python distribution installation
   on Linux and macOS.

### Fixed
 - Windows path conversion on Bash 3.2.

## [0.1.0] - 2019-10-24
### Added
 - Initial version of the script.
 - LICENSE file containing the GNU GPL3 text.
 - README file containing information about the expected UX and the initial
   direction of the project.

[Unreleased]: https://github.com/neimad/travis-python/compare/0.1.2...HEAD
[0.1.2]: https://github.com/neimad/travis-python/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/neimad/travis-python/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/neimad/travis-python/releases/tag/0.1.0
[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
