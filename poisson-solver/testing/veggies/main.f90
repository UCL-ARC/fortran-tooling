program veggies_main
    use veggies, only : test_item_t, test_that, run_tests
    use veggies_mesh_generator, only : test_mesh_generator
    use veggies_poisson, only : test_poisson
    use veggies_poisson_given_when_then, only : test_poisson_given_when_then
    implicit none

    if (.not.run()) stop 1

contains
    function run() result(passed)
        logical :: passed

        type(test_item_t) :: tests
        type(test_item_t) :: individual_tests(3)

        individual_tests(1) = test_mesh_generator()
        individual_tests(2) = test_poisson()
        individual_tests(3) = test_poisson_given_when_then()

        tests = test_that(individual_tests)

        passed = run_tests(tests)
    end function run
end program veggies_main