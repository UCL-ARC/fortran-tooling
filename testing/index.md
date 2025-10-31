---
title: Testing
---

<!-- Doxygen config
@page testing Testing
-->

Fortran code bases often have next to zero test coverage. Any tests implemented are fully end-to-end and often just check that a single value in some output file is what we expect it to be. Whilst a test like this can catch a breaking change or bug, it will be unlikely to indicate where that breaking change has been introduced. The solution to this issue is unit testing. 


There are several tools/frameworks written for unit testing Fortran code. However, these are not widely adopted by research codebases. We would like to understand why that is and help to change it.

There are several examples of good unit testing tools for other languages, such as

- pytest (Python)
- QtTest (Qt in c++)
- J-Unit (JavaScript)

These will be used as the basis for what the recommended Fortran unit testing tool should look like. Therefore, key features from these tools shall be individually tested for each Fortran unit testing tool we select to test.

# Template Features matrix

To aid in our recommendations of testing frameworks, we utilise the below matrix for tracking the capabilities
of each test framework.

Compilers tested: *A list of compilers we have tried with these tests*

| Feature | Implemented natively | Implemented manually |
|---------|----------------------|----------------------|
| Can run individual tests | Yes or No (explanation) | Yes or No (explanation) |
| Mocking/Stubbing | Yes or No (explanation) | Yes or No (explanation) |
| Data driven tests | Yes or No (explanation) | Yes or No (explanation) |
| Coverage report | Yes or No (explanation) | Yes or No (explanation) |
| Skip tests | Yes or No (explanation) | Yes or No (explanation) |
| Supports testing MPI parallel code | Yes or No (explanation) | Yes or No (explanation) |
| Supports testing OpenMP parallel code | Yes or No (explanation) | Yes or No (explanation) |

## Explanations 

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

Stubbing is very similar to mocking. The concept of stubbing is to have well-defined responses to procedure calls within a test which do not require calls to actual src code. For example, if we are want to test `functionB` which relies on some data which is usually returned from `functionA` which is compute intensive, we can essentially hard-code the response from `functionA` to speed up the test.
```f90
call stubbedFunctionA(data)    ! retrieve the hard coded data values from a stub
call functionB(data, output)  ! Use these hard coded values in out procedure being tested 
! Verify out output
```
This may seem overkill in the above example, but it becomes more important if we pass `functionA` into `functionB` and wanted to ensure this was stubbed.

The difference compared to mocking is that stubbing will not track calls to the mocked procedure/function/object whereas mocking will.

<!-- Doxygen config
**Subpages:** @subpage pfunit @subpage veggies @subpage test-drive
-->
