---
title: How to use this Repo
---

# Fortran Tooling

This repository aims to improve Fortran best practices within UCL and the wider Fortran community by documenting a growing list of Fortran tools recommended by [UCL ARC](https://ucl.ac.uk/arc).

## src code

There are two src codes within this repository [mesh_generator](./src/mesh_generator/) and [poisson](./src/poisson/). These are designed to work together.

- `mesh_generator` generates a basic square 2D triangular mesh (see [mesh_generator.f90](./src/mesh_generator/mesh_generator.f90) for more details).
- `poisson` is a solver which finds the solution of the steady-state heat conduction equation represented by the Poisson equation over a 2D triangular mesh (see [poisson.f90](./src/poisson/poisson.f90) for more details).

## Building

A bash [build.sh](./build.sh) script is provided for building all the source code and tests found in this repository. 
Optionally, the script can also install the project dependacies.  

The script provides both *CMake* and *fpm* backends for building the project, which can be ran with `./build.sh --build-cmake` or `./build.sh --build-fpm` respectively.  
Note that using the CMake backend requires a local installation of pFUnit (see more info in the CMake installation instructions).  

Alternatively, instructions for building the project without the script are provided below.
Instructions for installing pFUnit using the script are also provided.

### CMake

>Note: the CMake contains some [pFUnit tests](./testing/pFUnit/) which require a local version of pFUnit to be built on your device.
It can be installed either via the provided build.sh script or by following the installation instruction in the [pFUnit repo](https://github.com/Goddard-Fortran-Ecosystem/pFUnit).

To built the repository using cmake (see [CMakeLists.txt](./CMakeLists.txt)), please run the following

```sh
cmake -DCMAKE_PREFIX_PATH=</path/to/pfunit/installed/dir> -DBUILD_PFUNIT=ON -DBUILD_TEST_DRIVE=ON -B build-cmake 
``` 
This will create a [build](./build-cmake) directory and setup the build environment. To compile the code please run

```sh
cmake --build build-cmake
```

This will produce executables for the two src codes, `fortran-tooling-mesh-generator` and `fortran-tooling-poisson`.

### FPM

To build the project using FPM, from the root of the repo, run

```sh
fpm build
```

### pFUnit

The [build.sh](./build.sh) scripts provides a wrapper for simplifying the installation of pFUint.  To run the installer, execute

```sh
./build -p --build-pfunit --pfunit-dir=<PATH_TO_PFUINT>
```
where `<PATH_TO_PFUNIT>` is the **absolute** path to the local where pFUnit will be installed. Optionally, adding the flag `--test-pfunit` will test the pFUnit installation. 

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

If you have built using FPM, you can also run the mesh generator via FPM
```sh
fpm run poisson -- <path_to_mesh_file>
```

## Running the tests

If you have built using CMake, you can run the tests by running the following from within the `build-cmake` directory.

```sh
ctest
```

If you have built using FPM, you can run the tests by running the following from the root of the repo

```sh
fpm test
```

## pre-commit

[pre-commit](https://pre-commit.com/) is utilised within this repo. pre-commit is a tool to help enforce formatting standards as early as possible.
pre-commit works by running a provided set of checks every time a `git commit` is attempted.

To utilise pre-commit, it must be installed locally. This can be done in several ways but the easiest is to use the provided `requirements.txt` via...
```
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
``` 

Then, from the root of the repo, you start using pre-commit by running

```sh
pre-commit install
```

## Documentation

### Ford

To generate the Ford documentation locally run the command 

```sh
ford ford-home.md 
```

This will create a folder `ford-docs` within the root of the repo. Within `ford-docs` there will be an
`index.html` file. Open this file in a browser to view the generated documentation. Further
information about how Ford is set up within this repo is provided in the generated
documentation at `Tools->Documentation->Ford`.

> Note: the name of the output directory for our docs, `ford-docs`, is defined in [ford-home.md](./ford-home.md)
