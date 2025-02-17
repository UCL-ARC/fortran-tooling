# veggies

[Veggies](https://gitlab.com/everythingfunctional/veggies) is a unit testing framework for testing Fortran codes.
It has a sister project called [Garden](https://gitlab.com/everythingfunctional/garden) which acts as the same
testing framework but for codes which use coarray. *"The hope is that at some point in the future all compilers
will support parallel features implicitly, and any need for two separate packages will disappear."*

## Running the tests

The veggies tests will run with the rest of the FPM [tests](../README.md#running-the-tests) in the repo.

## Features matrix

Compilers tested: *A list of compilers we have tried with these tests*

| Feature | Implemented natively | Implemented manually |
|---------|----------------------|----------------------|
| Can run individual tests | Yes ( fpm test *"fpm test name"* [-- -f *"regex for test description"*] ) | N/A |
| Mocking | No | No |
| Stubbing | No | No |
| Data driven tests | Yes (via defining custom types which extend `input_t` type) | N/A |
| Coverage report | No | No |
| Skip tests | No | Sort of (return a generic pass with a description indicating test was skipped) |

## Pros

- Very clear test output with easy to read test descriptions and clear failures.
- Main developer is very responsive and open to contibutions.
- Integrates very well with fpm.

## Cons 

- Very few contibutors.
- Quite complex to get started.

## Building

with `fpm` it is a simple as `fpm build` and then `fpm test`

## Resources
- Repository: https://gitlab.com/everythingfunctional/veggies