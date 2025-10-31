---
title: Doxygen
---

<!-- Doxygen config
@page doxygen Doxygen
@ingroup documentation
-->

The [Doxygen]((https://www.doxygen.nl/)) tool is a widely-used tool for automatically generating documentation from a codebase.
It 

## Prerequisites

Min reqs:

- Python >= 2.7
- GNU tools `flex`, `bison`, `libiconv` and `GNU make`
- cmake >= 3.14

For all features:
- Qt >= 5.14
- A `latex` distribution
- [Graphvix](https://www.graphviz.org/) >= 2.38
- [Ghostscipt](https://www.ghostscript.com/)

## Installation

Installation is done from source via the Doxygen [download page](https://www.doxygen.nl/download.html).

Download the latest version for your operating system from that page, and follow the extensive [installation instructions](https://www.doxygen.nl/manual/install.html) provided by Doxyden.

## Use

The [User Manual](https://www.doxygen.nl/manual/index.html) is well documented and explains how the documentation keywords are read from docstring blocks.

There is a brief note on the specific comment style required for Fortran comments in the [Documenting the code](https://www.doxygen.nl/manual/docblocks.html#fortranblocks) section.
A comment block readable by `Doxygen` begins with `!>` or `!<`, and can be continued over multiple lines with `!!` or `!>`.
The usual Doxygen keywords then apply within these blocks.

An example subroutine would look like:

```Fortran
!> @brief    Write results to an output file
!! @details  Writes the generated mesh to a specified output file
!!
!! @param num_nodes        Number of nodes to write to the output file
!! @param num_elements     Number of elements to write to the output file
!! @param element_to_node  Values of the elements to write
!! @param coordinates      Co-ordinates of the node points to write
!! @param nodal_value_of_f Nodal value of f
!! @param file_io          Output file
subroutine write_output_file(num_nodes,num_elements,element_to_node,coordinates,nodal_value_of_f,file_io)
	implicit none
	
	integer, intent(in) :: num_nodes,num_elements,element_to_node(3,mxp),file_io
	real, intent(in)    :: nodal_value_of_f(mxp), coordinates(2, mxp)
	!...
end subroutine
```

## How we are using it

Our Doxygen configuration is defined in our [Doxyfile](./Doxyfile)

### Markdown preprocessing

To allow us to reuse the same markdown files for both our Ford and Doxygen documentation, we are making
use of the preprocessing capabilities of Doxygen. In our `Doxyfile` We have specified the following config.

```
ENABLE_PREPROCESSING = YES
FILTER_PATTERNS = *.md=./documentation/doxygen/strip_triple_dash_sections.py
```

This causes preprocessing to be run against all `*.md` files that have been discovered and not excluded by us.
This preprocessing is defined within [strip_triple_dash_sections.py](./strip_triple_dash_sections.py) which
removes any Ford specific configuration. For example,

```md
---
title: Tools
---
```

and uncomments any Doxygen config blocks. For example,

```md
<!-- Doxygen config
@page doxygen Doxygen
@ingroup documentation
-->
```

becomes

```md
@page doxygen Doxygen
@ingroup documentation
```
