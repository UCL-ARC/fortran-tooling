# UCL ARC Fortran Tooling Recommendations and Examples

This repository aims to improve Fortran best practices within UCL and the wider Fortran community by documenting a growing list of Fortran tools recommended by [UCL ARC](https://ucl.ac.uk/arc). 

## Topics covered

- benchmarking
- building
- compiling
- [debugging](./debugging)
- documentation
- formatting
- interfaces
- libraries
- package management
- profiling and tracing
- [testing](./testing)

## ARC Fortran projects 

| Name | Start | End | Repo | Opportunity | Tools | Lessons |
| --- | --- | --- | --- | --- | --- | --- |
| CONQUEST | May 2023 | May 2024 | [GitHub](https://github.com/OrderN/CONQUEST-release) | [#781](https://github.com/UCL-ARC/research-software-opportunities/issues/781) | Make, VTune, Advisor | |
| ALPS | Aug 2022 | Jul 2023 | [GitHub](https://github.com/danielver02/ALPS) | [#691](https://github.com/UCL-ARC/research-software-opportunities/issues/691) | Autotools, Ford | |
| FruitDemand | Apr 2021 | Mar 2023 |  | [#382](https://github.com/UCL-ARC/research-software-opportunities/issues/382) |  Make, Ford, PFUnit | |
| Trove | Jan 2021 | Aug 2021 | | [#404](https://github.com/UCL-ARC/research-software-opportunities/issues/404) | | |
| Zacros | Jan 2021 | Sep 2022 | | [#349](https://github.com/UCL-ARC/research-software-opportunities/issues/349) & older | CMake, CTest | | 

## src code

There are two src codes within this repository [mesh_generator](./src/mesh_generator/) and [poisson](./src/poisson/). These are designed to work together. 
- `mesh_generator` generates a basic square 2D triangular mesh (see [mesh_generator.f90](./src/mesh_generator/mesh_generator.f90) for more details).
- `poisson` is a solver which finds the solution of the steady-state heat conduction equation represented by the Poisson equation over a 2D traingular mesh (see [poisson.f90](./src/poisson/poisson.f90) for more details).

## Building

We are utilising cmake (see [CMakeLists.txt](./CMakeLists.txt)) for our build system. Therefore, to build this repository, please run the following
```sh
cmake -B build 
``` 
This will create a [build](./build) directory from within which the project can be compiled...
```sh
cd build
make
```
This will produce executables for the two src codes, `fortran-tooling-mesh-generator` and `fortran-tooling-poisson`.

## Running the src

### Mesh generator

```sh
./build/fortran-tooling-mesh-generator <box_size> <edge_size>
```

### Poisson solver

```sh
./build/fortran-tooling-poisson # then respond to prompt with the mesh name, likely to be `square_mesh`
```

## Running the tests

To run the tests run `ctest` from within the `build` directory.
