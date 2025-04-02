!> test-drive tests for mesh_generator::calculate_mesh
module test_drive_calculate_mesh
    use, intrinsic :: iso_fortran_env, only : int64, real64
    use testdrive, only : new_unittest, unittest_type, error_type, check

    use mesh_generator, only : calculate_mesh

    implicit none

    public

    real(kind=real64) :: test_threshold = 1e-06

    !> Type defining the inputs for tests of the calculate_mesh subroutine
    type :: calculate_mesh_inputs
        !> The input num_edges_per_boundary of the mesh for this test
        integer(kind=int64) :: num_edges_per_boundary
        !> The input num_nodes of the mesh for this test
        integer(kind=int64) :: num_nodes
        !> The input num_elements of the mesh for this test
        integer(kind=int64) :: num_elements
        !> The input num_boundary_nodes of the mesh for this test
        integer(kind=int64) :: num_boundary_nodes
    end type calculate_mesh_inputs

    !> Type defining the expected outputs for tests of the calculate_mesh subroutine
    type :: calculate_mesh_expected_ouputs
        !> The expected elements to be outputted for the given inputs
        integer(kind=int64), dimension(:, :), allocatable :: elements
        !> The expected boundary_edges to be outputted for the given inputs
        integer(kind=int64), dimension(:, :), allocatable :: boundary_edges
        !> The expected nodes to be outputted for the given inputs
        real(kind=real64), dimension(:, :), allocatable :: nodes
    end type calculate_mesh_expected_ouputs
contains

    !> Collect all test in this module into a single test suite
    subroutine collect_calculate_mesh_testsuite(testsuite)
        !> An array of unittest_types in which to store this suite's tests
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("test_calculate_mesh_8_2_8_9", test_calculate_mesh_8_2_8_9) &
            ]
    end subroutine collect_calculate_mesh_testsuite

    !> A unit test template for the calculate_mesh subroutine.
    subroutine verify_calculate_mesh(error, inputs, expected_outputs)
        implicit none
        !> An allocatable error_type to track failing tests.
        type(error_type), allocatable, intent(out) :: error
        !> A structure containing the required inputs for calling calculate_mesh.
        type(calculate_mesh_inputs), intent(in) :: inputs
        !> A structure containing the outputs we expect for the provided inputs.
        type(calculate_mesh_expected_ouputs), intent(in) :: expected_outputs

        integer(kind=int64), dimension(3, inputs%num_elements) :: actual_elements
        integer(kind=int64), dimension(3, inputs%num_boundary_nodes) :: actual_boundary_edges
        real(kind=real64), dimension(2, inputs%num_nodes) :: actual_nodes
        real(kind=real64), parameter :: threshold = 1e-06
        character(len=80) :: failure_message

        integer :: i, j

        call calculate_mesh(inputs%num_edges_per_boundary, inputs%num_nodes, inputs%num_elements, inputs%num_boundary_nodes, &
                            actual_nodes, actual_elements, actual_boundary_edges)

        do i = 1, inputs%num_elements
            do j = 1, 3
                write(failure_message,'(a,i1,a,i1,a,i2,a,i2)') "Unexpected value for elements(", j, ",", i, "), got ", &
                      actual_elements(j, i), " expected ", expected_outputs%elements(j, i)
                call check(error, actual_elements(j, i), expected_outputs%elements(j, i), failure_message)
                if (allocated(error)) return
            end do
        end do

        do i = 1, inputs%num_boundary_nodes
            do j = 1, 3
                write(failure_message,'(a,i1,a,i1,a,i2,a,i2)') "Unexpected value for boundary_edges(", j, ",", i, "), got ", &
                      actual_boundary_edges(j, i), " expected ", expected_outputs%boundary_edges(j, i)
                call check(error, actual_boundary_edges(j, i), expected_outputs%boundary_edges(j, i), failure_message)
                if (allocated(error)) return
            end do
        end do

        do i = 1, inputs%num_nodes
            do j = 1, 2
                write(failure_message,'(a,i1,a,i1,a,f3.1,a,f3.1)') "Unexpected value for nodes(", j, ",", i, "), got ", &
                      actual_nodes(j, i), " expected ", expected_outputs%nodes(j, i)
                call check(error, actual_nodes(j, i), expected_outputs%nodes(j, i), failure_message, thr=threshold)
                if (allocated(error)) return
            end do
        end do
    end subroutine verify_calculate_mesh

    !> A unit test for the calculate_mesh subroutine with num_boundary_nodes = 8,
    !> num_edges_per_boundary = 2, num_elements = 8 and num_nodes = 9
    subroutine test_calculate_mesh_8_2_8_9(error)
        implicit none
        !> An allocatable error_type to track if the test failed.
        type(error_type), allocatable, intent(out) :: error
        type(calculate_mesh_inputs) :: inputs
        type(calculate_mesh_expected_ouputs) :: expected_outputs
        ! Setup inputs
        inputs%num_boundary_nodes = 8
        inputs%num_edges_per_boundary = 2
        inputs%num_elements = 8
        inputs%num_nodes = 9

        ! Setup expected outputs
        allocate(expected_outputs%boundary_edges(3, inputs%num_nodes))
        expected_outputs%boundary_edges(:,1) = [1,2,1]
        expected_outputs%boundary_edges(:,2) = [2,3,2]
        expected_outputs%boundary_edges(:,3) = [3,6,2]
        expected_outputs%boundary_edges(:,4) = [6,9,6]
        expected_outputs%boundary_edges(:,5) = [9,8,8]
        expected_outputs%boundary_edges(:,6) = [8,7,7]
        expected_outputs%boundary_edges(:,7) = [7,4,7]
        expected_outputs%boundary_edges(:,8) = [4,1,3]
        allocate(expected_outputs%elements(3, inputs%num_elements))
        expected_outputs%elements(:,1) = [1,2,5]
        expected_outputs%elements(:,2) = [2,3,6]
        expected_outputs%elements(:,3) = [1,5,4]
        expected_outputs%elements(:,4) = [2,6,5]
        expected_outputs%elements(:,5) = [4,5,8]
        expected_outputs%elements(:,6) = [5,6,9]
        expected_outputs%elements(:,7) = [4,8,7]
        expected_outputs%elements(:,8) = [5,9,8]
        allocate(expected_outputs%nodes(2, inputs%num_nodes))
        expected_outputs%nodes(:,1) = [1.0,1.0]
        expected_outputs%nodes(:,2) = [1.0,2.0]
        expected_outputs%nodes(:,3) = [1.0,3.0]
        expected_outputs%nodes(:,4) = [2.0,1.0]
        expected_outputs%nodes(:,5) = [2.0,2.0]
        expected_outputs%nodes(:,6) = [2.0,3.0]
        expected_outputs%nodes(:,7) = [3.0,1.0]
        expected_outputs%nodes(:,8) = [3.0,2.0]
        expected_outputs%nodes(:,9) = [3.0,3.0]

        ! Call parent test
        call verify_calculate_mesh(error, inputs, expected_outputs)

        ! Teardown
        deallocate(expected_outputs%boundary_edges)
        deallocate(expected_outputs%elements)
        deallocate(expected_outputs%nodes)
    end subroutine test_calculate_mesh_8_2_8_9
end module test_drive_calculate_mesh
