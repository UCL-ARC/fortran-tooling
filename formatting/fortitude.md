# [Fortitude](https://fortitude.readthedocs.io/en/stable/)

## Prerequisite

A tool for installing - `pip` or `homebrew`

## Installation

The [quickstart page](https://fortitude.readthedocs.io/en/stable/#quickstart) for Fortitude details multiple ways of installing the tool.
To minimise the amount of non-Fortran build systems/dependency managers, it may be best to opt for the curl and sh install method.

## Usage in this repo

This repo has been formatted with Fortitude. To check this repo with Fortitude, simply run the following from the root of this repository

```sh
fortitude --config-file formatting/fortitude.toml check
```

The config file, [fortitude.toml](./fortitude.toml), we have provided in the above command contains our rules which alter the [default fortitude rules](https://fortitude.readthedocs.io/en/stable/rules/).

### pre-commit

We have also integrated Fortitude with pre-commit. To set this up, follow the [instructions on the main README.md](../README.md#pre-commit).
Once this is setup, if you then try and commit a poorly formatted Fortran file...

```sh
$ git commit -m "Adding a bad commit"       
Fortran Tooling hooks....................................................Failed
- hook id: fortran-tooling-hooks
- exit code: 1

testing/veggies/test_poisson.f90:2:5: C121 'use' statement missing 'only' clause
  |
1 | module veggies_poisson
2 |     use poisson
  |     ^^^^^^^^^^^ C121
3 |     use veggies, only: &
4 |             assert_equals, &
  |

fortitude: 1 files scanned.
Number of errors: 1

For more information about specific rules, run:

    fortitude explain X001,Y002,...
```

Fortitude has helpfully alerted us to our mistake. In the above case, we have tried to use a module without specificying which bits of
the module we require via an `only` clause. If we disagree with a rule we can investigate further by searching the rule ID, here the
rule ID is `C121` which has the description `'use' statement missing 'only' clause` and further info can be found on the
[Fortitude website](https://fortitude.readthedocs.io/en/stable/rules/use-all/)  
