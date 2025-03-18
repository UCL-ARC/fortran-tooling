# fortran-unit-testing

Fortran code bases often have next to zero test coverage. Any tests implemented are fully end to end and often just check that a single value in some output file is what we expect it to be. Whilst a test like this can catch a breaking change or bug, it will be unlikely to indicate where that breaking change has been introduced. The solution to this issue is unit testing.

There are several tools/frameworks written for unit testing Fortran code. However, these are not widely adopted by research codebases. We would like to understand why that is and help to change it.

There are several examples of good unit testing tools for other languages, such as

- pytest (Python)
- QtTest (Qt in c++)
- J-Unit (JavaScript)

These will be used as the basis for what the recommended Fortran unit testing tool should look like. Therefore, key features from these tools shall be individually tested for each Fortran unit testing tool we select to test.

## Running all of the tests

All of the test can be ran from within the build directory with the command `ctest`. However, there is a known issue that the tests for test-drive itself will also be ran, as shown below.

```sh
$ ctest   
Test project /Users/connoraird/work/fortran-tooling/build
    Start 1: fortran-tooling-test-drive/mesh_generator
1/4 Test #1: fortran-tooling-test-drive/mesh_generator ...   Passed    0.33 sec
    Start 2: test-drive/all-tests
2/4 Test #2: test-drive/all-tests ........................   Passed    0.33 sec
    Start 3: test-drive/check
3/4 Test #3: test-drive/check ............................   Passed    0.01 sec
    Start 4: test-drive/select
4/4 Test #4: test-drive/select ...........................   Passed    0.01 sec

100% tests passed, 0 tests failed out of 4

Total Test time (real) =   0.69 sec
```

## Template Features matrix

Compilers tested: *A list of compilers we have tried with these tests*

| Feature | Implemented natively | Implemented manually |
|---------|----------------------|----------------------|
| Can run individual tests | Yes or No (explanation) | Yes or No (explanation) |
| Mocking/Stubbing | Yes or No (explanation) | Yes or No (explanation) |
| Data driven tests | Yes or No (explanation) | Yes or No (explanation) |
| Coverage report | Yes or No (explanation) | Yes or No (explanation) |
| Skip tests | Yes or No (explanation) | Yes or No (explanation) |

### Explanations 

**Mocking**

There are many good explanations of what mocking is, [here is one](https://www.hypertest.co/unit-testing/unit-test-mocking) (this is summarised below)

**What is Mocking?**

Mocking is a technique used in unit testing to replace real objects with mock objects. These mock objects simulate the behaviour of real objects, allowing the test to focus on the functionality of the unit being tested. Mocking is particularly useful when the real objects are complex, slow, or have undesirable side effects (e.g., making network requests, accessing a database, or depending on external services).

**Why Use Mocking?**

- *Isolation:* By mocking dependencies, you can test units in isolation without interference from other parts of the system.

- *Speed:* Mocking eliminates the need for slow operations such as database access or network calls, making tests faster.

- *Control:* Mock objects can be configured to return specific values or throw exceptions, allowing you to test different scenarios and edge cases.

- *Reliability:* Tests become more predictable as they don't depend on external systems that might be unreliable or unavailable.

**Stubbing**

Stubbing is very similar to mocking. The concept of stubbing is to have well-defined responses to procedure calls within a test which do not require calls to actual src code. For example, if we are want to test `functionAB` which relies on some data which is usually returned from `functionA` which is compute intensive, we can essentially hard-code the response from `functionA` to speed up the test.
```f90
call stubbedFunctionA(data)    ! retrieve the hard coded data values from a stub
call functionB(data, output)  ! Use these hard coded values in out procedure being tested 
! Verify out output
```
This may seem overkill in the above example, but it becomes more important if we pass `functionA` into `functionB` and wanted to ensure this was stubbed.

The difference compared to mocking is that stubbing will not track calls to the mocked procedure/function/object whereas mocking will.
