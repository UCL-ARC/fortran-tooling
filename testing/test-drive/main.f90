!> Driver for unit testing
program tester
    use, intrinsic :: iso_fortran_env, only : error_unit
    use testdrive, only : run_testsuite, new_testsuite, testsuite_type, &
        & select_suite, run_selected, get_argument

    use test_drive_mesh_generator, only : collect_mesh_generator_testsuite
    use test_drive_poisson, only : collect_poisson_testsuite

    implicit none

    integer :: stat, is
    character(len=:), allocatable :: suite_name, test_name
    type(testsuite_type), allocatable :: testsuites(:)
    character(len=*), parameter :: fmt = '("#", *(1x, a))'

    stat = 0

    testsuites = [ &
        new_testsuite("mesh_generator", collect_mesh_generator_testsuite), &
        new_testsuite("poisson", collect_poisson_testsuite) &
        ]

    call get_argument(1, suite_name)
    call get_argument(2, test_name)

    write(error_unit, fmt) "Running test-drive tests suite"
    if (allocated(suite_name)) then
        is = select_suite(testsuites, suite_name)
        if (is > 0 .and. is <= size(testsuites)) then
            if (allocated(test_name)) then
                write(error_unit, fmt) "Suite:", testsuites(is)%name
                call run_selected(testsuites(is)%collect, test_name, error_unit, stat)
                if (stat < 0) then
                    error stop 1
                end if
            else
                write(error_unit, fmt) "Testing:", testsuites(is)%name
                call run_testsuite(testsuites(is)%collect, error_unit, stat)
            end if
        else
            write(error_unit, fmt) "Available testsuites"
            do is = 1, size(testsuites)
                write(error_unit, fmt) "-", testsuites(is)%name
            end do
            error stop 1
        end if
    else
        do is = 1, size(testsuites)
            write(error_unit, fmt) "Testing:", testsuites(is)%name
            call run_testsuite(testsuites(is)%collect, error_unit, stat)
        end do
    end if

    if (stat > 0) then
        write(error_unit, '(i0, 1x, a)') stat, "test(s) failed!"
        error stop 1
    end if

end program tester