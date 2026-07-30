---
title: Fortitude
---

<!-- Doxygen config
@page fortitude Fortitude
@ingroup formatting
-->

[Fortitude](https://fortitude.readthedocs.io/en/stable/) is a Fortran linter, inspired by (and built upon) Ruff.

## Prerequisite

A tool for installing, i.e. `pip` or `homebrew`

## Installation

To install fortitude we can utilise the provided `requirements.txt` by following install instructions in the developer docs. The
[quickstart page](https://fortitude.readthedocs.io/en/stable/#quickstart) for Fortitude details multiple other ways of installing
the tool.

## Usage in this repo

This repo has been formatted with Fortitude. To check this repo with Fortitude, simply run the following from the root of this repository

```sh
fortitude --config-file formatting/fortitude/fortitude.toml check
```

The config file, [fortitude.toml](./fortitude.toml), we have provided in the above command contains our rules which alter the
[default fortitude rules](https://fortitude.readthedocs.io/en/stable/rules/).

### prek

We have also integrated Fortitude with prek. To set this up, follow the instructions in the developer docs.
Once this is set up, if you then try and commit a poorly formatted Fortran file:

```sh
$ git commit -m "Adding a bad commit"
fortitude................................................................Failed
- hook id: fortitude
- exit code: 1

  game-of-life/src/main.f90:10:5: C121 'use' statement missing 'only' clause
     |
   8 |     ! allow(C121)
   9 |     use mpi
  10 |     use cli
     |     ^^^^^^^ C121
  11 |     use game_of_life, only : check_for_steady_state, evolve_board, find_steady_state
  12 |     use io, only : read_model_from_file
     |

  fortitude: 1 files scanned.
  Number of errors: 1

  For more information about specific rules, run:

      fortitude explain X001,Y002,...
```

Fortitude has helpfully alerted us to our mistake. In the above case, we have tried to use a module without specifying which bits of
the module we require via an `only` clause. If we disagree with a rule we can investigate further by searching the rule ID, here the
rule ID is `C121` which has the description `'use' statement missing 'only' clause` and further info can be found on the
[Fortitude website](https://fortitude.readthedocs.io/en/stable/rules/use-all/)
