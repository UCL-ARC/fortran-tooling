---
title: Developer Docs
---

<!-- Doxygen config
@page developer-docs Developer Docs
-->

This repository aims to improve Fortran best practices within UCL and the wider Fortran community by documenting a growing list of
Fortran tools recommended by [UCL ARC](https://ucl.ac.uk/arc).

## src code

An implementation of [Conway's game of life](./game-of-life/) is provided as src code. We utilise this src code to provide examples
of how to use our recommended Fortran tools.

## pre-commit

[pre-commit](https://pre-commit.com/) is utilised within this repo. pre-commit is a tool to help enforce formatting standards as
early as possible. pre-commit works by running a provided set of checks every time a `git commit` is attempted.

To utilise pre-commit, it must be installed locally. This can be done in several ways but the easiest is to use the provided
`requirements.txt` via:

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

Then, from the root of the repo, you start using pre-commit by running

```sh
pre-commit install
```

## Generating documentation

### Ford docs

To generate the Ford documentation locally run the command

```sh
ford ford-home.md
```

This will create a folder `docs/ford-docs` within the root of the repo. Within `docs/ford-docs` there will be an
`index.html` file. Open this file in a browser to view the generated documentation. Further
information about how Ford is set up within this repo is provided in the generated
documentation at `Tools->Documentation->Ford`.

### Doxygen docs

To generate the Doxygen documentation locally run the command

```sh
doxygen documentation/doxygen/Doxyfile
```

This will create a folder `docs/doxygen-docs` within the root of the repo. Within `docs/doxygen-docs` there will
be an `index.html` file. Open this file in a browser to view the generated dociumentation. Further information
about how Doxygen is set up within this repo is provided in the generated documentation at
`Tools->documentation->Doxygen`.
