---
title: Prek
---

<!-- Doxygen config
@page prek Prek
@ingroup formatting
-->

[prek](https://prek.j178.dev/) is a tool for automating quality checks that run right before a git commit is finalised. These
hooks help enforce consistent styling and remove the need for trivial changes to be requested on pull requests as they will have
already been caught before committing.

## Prerequisite

A tool for installing, `uv`, `pip`, `homebrew`, etc.

## Installation

To install prek follow their [installation instructions](https://prek.j178.dev/installation/)

## Usage in this repo

We utilise prek to enforce our chosen quality check rules. These rules are primarily defined in the `.pre-commit-config.yaml`. This
file defines the pre-commit hooks we wish to enforce.

For example, we are enforce that Fortran files pass the [fortitude](../fortitude/index) linting checks:

```yaml
- repo: https://github.com/PlasmaFAIR/fortitude-pre-commit
  rev : v0.8.0
  hooks:
  - id: fortitude
    args:
    - --config-file=formatting/fortitude/fortitude.toml
```

We also make use of other files to further configure our chosen quality checks (i.e `.vale.ini`, `.typos.toml`, `.markdownlint.yaml`).
