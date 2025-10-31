---
title: documentation
---

<!-- Doxygen config
@page documentation Documentation
@ingroup tools
@subpage doxygen
@subpage ford
-->

Building documentation from your source code has widely been used for a long time, and now commonly used tools like Doxygen work with Fortran.

A number of automated documentation generation projects for Fortran have come and gone over the years, and below are documented a number of them.
At the top of the list are the recommended and still supported documentation tools.

## Candidate Tools

| Tool | Description | Known issues |
| ---- | ------ | ----- |
| **Recommended** |||
| [Doxygen](https://www.doxygen.nl/) | Commonly used documentation tool for large repositories. Officially supports Fortran with language-specific docblocks. See `doxygen/index.md` for details on use. | <ul><li> Examples are somewhat outdated </li><li> Support traditionally has not been great </li></ul> |
| [FORD](https://github.com/Fortran-FOSS-Programmers/ford) | Created due to Doxygen's lack of Fortran compatability, FORtran Documentater (FORD) is an independent automatic documenter for modern Fortran. See `ford/index.md` for details on use. | <ul><li> Not the healthiest repository </li><li> Not as feature rich as Doxygen (in principle) </ul> |
| **Dead projects** | | |
| [ROBODoc](https://rfsber.home.xs4all.nl/Robo/) | Automatic parsing of any comment-enabled language into various output formats | <ul><li>Last updated 2021</li><li> Various links no longer work </li><li> Cannot actually extract information correctly from Fortran </li></ul> |
| [Doctran](https://github.com/CPardi/Doctran) | Cross-platform documentation generator specifically designed for Fortran | <ul><li> Last updated 9 years ago </li><li> Homepage examples et al no longer exist </li></ul> |
| [f90tohtml](https://code.google.com/archive/p/f90tohtml/) | | Last revision 2009 |
| [f90doc](https://fortranwiki.org/fortran/show/f90doc) | The basis for FORD | Last revision 2005 |
