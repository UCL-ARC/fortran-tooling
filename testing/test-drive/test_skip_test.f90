!> test-drive test to demonstrate the skip_test feature
module test_drive_skip_test
    use testdrive, only : new_unittest, unittest_type, error_type, skip_test
    implicit none

    public

contains

    !> Collect all test in this module into a single test suite
    subroutine collect_skip_test_testsuite(testsuite)
        !> An array of unittest_types in which to store this suite's tests
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("test_skip_example", test_skip_example) &
            ]
    end subroutine collect_skip_test_testsuite

    !> A unit test to demonstrate test-drives ability to skip a test
    subroutine test_skip_example(error)
        !> An allocatable error_type to track failing tests.
        type(error_type), allocatable, intent(out) :: error
        call skip_test(error, "This feature is not implemented yet")
        return
    end subroutine test_skip_example
end module test_drive_skip_test
