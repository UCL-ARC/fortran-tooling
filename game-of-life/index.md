---
title: Game of Life
---

<!-- Doxygen config
@page game-of-life Game of Life
-->

Take a look at the [src](./game-of-life/src/) code provided. This is an MPI parallelized implementation of
[Conway's game of life](http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life). The program reads in a data file which represents
the starting state of the system. The system is then evolved.

To build and run the src code you can use one of the following commands from within this dir.

#### CMake

```bash
cmake -B build-cmake
cmake --build build-cmake
mpirun -np <num_mpi_ranks> ./build-cmake/game-of-life ../models/model-1.dat # Or another data file
```

#### Make

```bash
make game_of_life
```

#### FPM

```bash
fpm build
```

## Tests

There [tests](./test/) provided have been written using [pFUnit](link/somewhere). To compile and run these tests using CMake, use:

```bash
# We must provide the path to the directory where pFUnit is installed
cmake -B build-cmake -DCMAKE_PREFIX_PATH=/path/to/pfunit/install
cmake --build build-cmake
ctest --test-dir build-cmake --output-on-failure
```

or with Make:

```bash
PFUNIT_INCLUDE_DIR=/path/to/pfunit/install make tests
mpirun -np <num_ranks> ./test/tests
```

fpm does not currently support pFUnit thus we cannot build the tests using fpm.

> Note: pFUnit relies on python to generate the tests and this must be available on your path as `python` (i.e. `python3` will not
> work)

### Building pFUnit

To execute the tests, the pFUnit library needs to be built locally. For convenience a [script](./scripts/build-pfunit.sh) is
provided to fetch and build pFUnit. Run this script with the `-h` flag for more information.
