program garden_main
    use garden, only : test_item_t, test_that, run_tests
    use garden_mesh_generator, only : test_mesh_generator
    use garden_poisson, only : test_poisson
    implicit none

    if (.not.run()) stop 1

contains
    function run() result(passed)
        logical :: passed

        type(test_item_t) :: tests
        type(test_item_t) :: individual_tests(2)

        individual_tests(1) = test_mesh_generator()
        individual_tests(2) = test_poisson()
        
        tests = test_that(individual_tests)

        passed = run_tests(tests)
    end function run
end program garden_main