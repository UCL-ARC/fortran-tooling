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
| LFRic | Sept 2024 | March 2025 | [GitHub](https://github.com/exoclim/lfric_dev) | [#594](https://github.com/UCL-ARC/research-software-opportunities/issues/594) | Rose, Cylc | |
| CONQUEST | May 2023 | May 2024 | [GitHub](https://github.com/OrderN/CONQUEST-release) | [#781](https://github.com/UCL-ARC/research-software-opportunities/issues/781) | Make, VTune, Advisor | |
| ALPS | Aug 2022 | Jul 2023 | [GitHub](https://github.com/danielver02/ALPS) | [#691](https://github.com/UCL-ARC/research-software-opportunities/issues/691) | Autotools, Ford | |
| FruitDemand | Apr 2021 | Mar 2023 |  | [#382](https://github.com/UCL-ARC/research-software-opportunities/issues/382) |  Make, Ford, PFUnit | |
| Trove | Jan 2021 | Aug 2021 | [GitHub](https://github.com/Trovemaster/TROVE/tree/merge-develop-mpi) | [#404](https://github.com/UCL-ARC/research-software-opportunities/issues/404) | Make, pFUnit (see the [PR](https://github.com/Trovemaster/TROVE/pull/44/files#diff-beda42571c095172ab63437d050612a571d0d9ddd3ad4f2aecbce907a9b7e3d0)) | |
| Zacros | Jan 2021 | Sep 2022 | | [#349](https://github.com/UCL-ARC/research-software-opportunities/issues/349) & older | CMake, CTest | | 

## src code

There are two src codes within this repository [mesh_generator](./src/mesh_generator/) and [poisson](./src/poisson/). These are designed to work together. 
- `mesh_generator` generates a basic square 2D triangular mesh (see [mesh_generator.f90](./src/mesh_generator/mesh_generator.f90) for more details).
- `poisson` is a solver which finds the solution of the steady-state heat conduction equation represented by the Poisson equation over a 2D traingular mesh (see [poisson.f90](./src/poisson/poisson.f90) for more details).

## Building

A bash script is provided for building ([build.sh](./build.sh)). However, there are some instructions below for building without this script.

### CMake
>Note: we have some [PFunit tests](./testing/pFUnit/) which require a local version of PFunit to be pre-built on your device. Once built, the path to the PFunit `installed` dir will need to be passed via `-DCMAKE_PREFIX_PATH`.

One build system we are utilising is cmake (see [CMakeLists.txt](./CMakeLists.txt)). Therefore, to build this repository, please run the following
```sh
cmake -DCMAKE_PREFIX_PATH=/path/to/pfunit/installed/dir -B build-cmake 
``` 
This will create a [build](./build) directory from within which the project can be compiled...
```sh
cmake --build build-cmake
```
This will produce executables for the two src codes, `fortran-tooling-mesh-generator` and `fortran-tooling-poisson`.

### FPM
To build the project using FPM, from the root of the repo, run
```sh
fpm build
```

## Running the src

### Mesh generator
If you have built using CMake, you can run the mesh generator by directly calling the executable
```sh
./build/fortran-tooling-mesh-generator <box_size> <edge_size>
```

If you have built using FPM, you can also run the mesh generator via FPM
```sh
fpm run mesh_generator -- <box_size> <edge_size>
```

### Poisson solver
If you have built using CMake, you can also run the poisson solver by directly calling the executable
```sh
./build/fortran-tooling-poisson <path_to_mesh_file>
```

If you have built using FPM, you can run the mesh generator via FPM
```sh
fpm run poisson -- <path_to_mesh_file>
```

## Running the tests
If you have built using CMake, you can run the tests by running the following from within the `build-cmake` directory.
```sh
ctest
```

If you have built using fpm, you can run the tests by running the following from the root of the repo
```sh
fpm test
```
