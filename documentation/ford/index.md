---
title: Ford
---
<!-- Doxygen config
@page ford Ford
@ingroup documentation
-->

FORtran Documenter ([FORD]((https://github.com/Fortran-FOSS-Programmers/ford))) is an automatic documentation generater designed for Fortran.

Originally conveived due to Doxygen's historical lack of Fortran support, FORD has turned into a well established and feature-rich documentation project.
See [the FORD repository](https://github.com/Fortran-FOSS-Programmers/ford) for a full description of the features available.

TODO list some of the useful bits we're interested in here/are unique from Doxygen?

## Installation

Installation (and automatic handling of dependencies) can be done through pip:

```sh
pip install ford
```

Installation is also available through Homebrew with the following commands:

```sh
brew update
brew install FORD
```

There is also a spack package available to install FORD:

```sh
spack install py-ford
```

## Use within this repo

We have used Ford to generate this documentation.

### Technical documentation

The docstrings within the src and test code will be picked up by Ford which then automatically
generates technical documentation pages which you can explore using the tabs at the top of the
generated website.

For a docstring to be picked up by Ford it should begin with `!>`. To add a docstring to a module,
for example, we do the following.

```f90
!> Module for doing something cool
!> 
!> It does this cool thing by being good
module cool_mod
    !...
end module cool_mod
```

This is the structure for all docstrings, including for subroutines, functions, programs and
arguments. For example,

```f90
!> Program for doing something cool
!> 
!> It does this cool thing by being good
program cool_prog
    use cool_mod
    implicit none
contains
    !> Function which does something
    function some_function(some_variable)
        !> A nice variable
        integer, intent(in) :: some_variable
        !...
    end function some_function

    !> Subroutine which does something
    subroutine some_subroutine(some_variable)
        !> A nice variable
        integer, intent(in) :: some_variable
        !...
    end subroutine some_subroutine
end program cool_prog
```

> Note: `!>` is set by us as the allowed "predocmark" within our `README.md`. The standard way to
> document with Ford is to place a dosctring starting with `!!` after the entity you are
> documenting, but this is less standard in other languages, hence why we are using a predocmark.

### Static pages

As well as the technical documentation we have also written static pages which contain information
about how we have used various tools and our opinions/recommendations regarding them. These pages
are organised following the [instructions defined in the Ford documentation](https://forddocs.readthedocs.io/en/stable/user_guide/writing_pages.html).

Essentially, there is an `index.md` at the root of our repository which allows us to specify that
the `page_dir` Ford should use as the root of our static page hierarchy is the root of our
repository. We do this within the header of the `README.md`. 

```yaml
page_dir: .
```

With this information, Ford will then search all subdirectories for an `index.md` with a
header containing a title like so.

```
---
title: Tools
---
```

If one is found, this will be added as a static page. We can add further subpages by adding
`.md` files within the same dir as the `index.md` discovered by Ford and again adding a
similar header containing a title. We can also add subpages by including additional `index.md`
files within further subdirectories and again the process repeats. For example, the following
file structure...

```
root of repo
|-- index.md (title: Tools)
|-- documentation
    |-- index.md (title: Documentation)
|   |-- doxygen.md (title: Doxygen)
|   |-- ford
|       |-- index.md (title: Ford)
|-- testing
|   |-- index.md (title: Testing)
|   |-- pfunit
|       |-- index.md (title: pFUnit)
|-- src
    |-- README.md 
```

would produce the following static page structure (notice src is ignored as it does not
contain and `index.md` with a title).

```
Tools
|-- Documentation
|   |-- Doxygen
|   |-- Ford
|-- Testing
    |-- pFUnit
```
