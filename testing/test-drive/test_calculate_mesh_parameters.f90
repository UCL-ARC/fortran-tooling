!> test-drive tests for mesh_generator::calculate_mesh_parameters
module test_drive_calculate_mesh_parameters
    use, intrinsic :: iso_fortran_env, only : int64, real64
    use testdrive, only : new_unittest, unittest_type, error_type, check

    use mesh_generator, only : calculate_mesh_parameters

    implicit none

    public

    real(kind=real64) :: test_threshold = 1e-06

    !> Type defining the inputs for tests of the calculate_mesh_parameters subroutine
    type :: calculate_mesh_parameters_inputs
        !> The input edge_size of the mesh for this test
        real(kind=real64)   :: edge_size
        !> The input box_size of the mesh for this test
        integer(kind=int64) :: box_size
    end type calculate_mesh_parameters_inputs

    !> Type defining the expected outputs for tests of the calculate_mesh_parameters subroutine
    type :: calculate_mesh_parameters_expected_ouputs
        !> The expected num_edges_per_boundary to be outputted for the given inputs
        integer(kind=int64) :: num_edges_per_boundary
        !> The expected num_nodes to be outputted for the given inputs
        integer(kind=int64) :: num_nodes
        !> The expected num_boundary_nodes to be outputted for the given inputs
        integer(kind=int64) :: num_boundary_nodes
        !> The expected num_elements to be outputted for the given inputs
        integer(kind=int64) :: num_elements
    end type calculate_mesh_parameters_expected_ouputs
contains

    !> Collect all test in this module into a single test suite
    subroutine collect_calculate_mesh_parameters_testsuite(testsuite)
        !> An array of unittest_types in which to store this suite's tests
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("test_calculate_mesh_parameters_5_1", test_calculate_mesh_parameters_5_1), &
            new_unittest("test_calculate_mesh_parameters_10_05", test_calculate_mesh_parameters_10_05) &
            ]
    end subroutine collect_calculate_mesh_parameters_testsuite

    !> A unit test template for the calculate_mesh_parameters subroutine.
    subroutine verify_calculate_mesh_parameters(error, inputs, expected_outputs)
        implicit none
        !> An allocatable error_type to track failing tests.
        type(error_type), allocatable, intent(out) :: error
        !> A structure containing the required inputs for calling calculate_mesh_parameters.
        type(calculate_mesh_parameters_inputs), intent(in) :: inputs
        !> A structure containing the outputs we expect for the provided inputs.
        type(calculate_mesh_parameters_expected_ouputs), intent(in) :: expected_outputs

        integer(kind=int64) :: actual_num_edges_per_boundary, actual_num_nodes,  &
                   actual_num_boundary_nodes, actual_num_elements

        call calculate_mesh_parameters(inputs%box_size, inputs%edge_size, &
                actual_num_edges_per_boundary, actual_num_nodes,              &
                actual_num_boundary_nodes, actual_num_elements)

        call check(error, expected_outputs%num_boundary_nodes,     actual_num_boundary_nodes)
        call check(error, expected_outputs%num_edges_per_boundary, actual_num_edges_per_boundary)
        call check(error, expected_outputs%num_elements,           actual_num_elements)
        call check(error, expected_outputs%num_nodes,              actual_num_nodes)

        ! Catch test failure
        if (allocated(error)) return
    end subroutine verify_calculate_mesh_parameters

    !> A unit test for the calculate_mesh_parameters subroutine with box_size = 5 and edge_size = 1.0
    subroutine test_calculate_mesh_parameters_5_1(error)
        implicit none
        !> An allocatable error_type to track if the test failed.
        type(error_type), allocatable, intent(out) :: error
        type(calculate_mesh_parameters_inputs) :: inputs
        type(calculate_mesh_parameters_expected_ouputs) :: expected_outputs
        ! Setup inputs
        inputs%box_size = 5
        inputs%edge_size = 1.0
        ! Setup expected outputs
        expected_outputs%num_boundary_nodes = 20
        expected_outputs%num_edges_per_boundary = 5
        expected_outputs%num_elements = 50
        expected_outputs%num_nodes = 36
        ! Call parent test
        call verify_calculate_mesh_parameters(error, inputs, expected_outputs)
    end subroutine test_calculate_mesh_parameters_5_1

    !> A unit test for the calculate_mesh_parameters subroutine withand box_size = 10 and edge_size = 0.5
    subroutine test_calculate_mesh_parameters_10_05(error)
        implicit none
        !> An allocatable error_type to track if the test failed.
        type(error_type), allocatable, intent(out) :: error
        type(calculate_mesh_parameters_inputs) :: inputs
        type(calculate_mesh_parameters_expected_ouputs) :: expected_outputs
        ! Setup inputs
        inputs%box_size = 10
        inputs%edge_size = 0.5
        ! Setup expected outputs
        expected_outputs%num_boundary_nodes = 80
        expected_outputs%num_edges_per_boundary = 20
        expected_outputs%num_elements = 800
        expected_outputs%num_nodes = 441
        ! Call parent test
        call verify_calculate_mesh_parameters(error, inputs, expected_outputs)
    end subroutine test_calculate_mesh_parameters_10_05
end module test_drive_calculate_mesh_parameters
