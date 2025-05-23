# pFUnit
pFUnit is a unit testing framework enabling JUnit-like testing of serial and MPI-parallel software written in Fortran. Limited support for OpenMP is also provided in the form of managing exceptions in a thread-safe manner.

pFUnit uses several advanced Fortran features, especially object oriented capabilities, to offer a convenient, lightweight mechanism for Fortran developers to create and run software tests that specify the desired behavior for a given piece of code.

This framework was originally created by developers from NASA and NGC TASC.

## Running the tests

>Note: Before being able to run these tests you must have pFUnit cloned and built locally. To do this follow the instructions on the [pFUnit repo](https://github.com/Goddard-Fortran-Ecosystem/pFUnit)

The pFUnit tests will run with the rest of the cmake [tests](../README.md#running-the-tests) in the repo.

## Features matrix

Compilers tested: GNU Fortran (Homebrew GCC 14.2.0_1)

| Feature | Implemented natively | Implemented manually |
|---------|----------------------|----------------------|
| Can run individual tests | Yes (by directly calling the test executable, not ctest, we can pass `-f` to filter tests by name) | N/A |
| Mocking/Stubbing | No | No |
| Data driven tests | Yes (see [test_calculate_mesh_parameters.pf](./test_calculate_mesh_parameters.pf)) | N/A |
| Coverage report | Yes or No (explanation) | Yes or No (explanation) |
| Skip tests | Partially, but there is no logging of skipped tests (add required pre-compile flag e.g. `@Test(#ifdef NO_SKIP)`) | Partially (comment `@Test` annotation) |


## Pros

## Cons
- pFUnit must be built locally before it can be used within this project
- Due to the heavy use of F2003 object oriented features and a smattering of F2008 features, only relatively recent Fortran compilers are able to correctly build pFUnit.
- Several unfinished features still present in the repo such as mocking.

## Resources
- Repository: https://github.com/Goddard-Fortran-Ecosystem/pFUnit
- Webinar: [Testing Fortran Software with pFUnit](https://ideas-productivity.org/events/hpcbp-028-pfunit)