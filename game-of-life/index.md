---
title: Game of Life
---

<!-- Doxygen config
@page game-of-life Game of Life
-->

Take a look at the [src](./game-of-life/src/) code provided. This is an MPI parallelized implementation of
[Conway's game of life](http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life). The program reads in a data file which represents
the starting state of the system. The system is then evolved.

To build and run the src code use the following commands from within this dir.

```bash
cmake -B build-cmake -DCMAKE_PREFIX_PATH=/path/to/pfunit/install
cmake --build build-cmake
mpirun -np <num_mpi_ranks> ./build-cmake/game-of-life ../models/model-1.dat # Or another data file
```

Alternatively, this code can be built using make via the following command.

```bash
PFUNIT_INCLUDE_DIR="/path/to/pfunit/install" make build
```

## Tests

There [tests]() provided have been written using [pFUnit](link/somewhere). 

### Building pFUnit

To execute the tests, the pFUnit library needs to be built locally. For convenience a [script](./scripts/build-pfunit.sh) is provided to fetch and build pFUnit. Run this script with the `-h` flag for more information.
