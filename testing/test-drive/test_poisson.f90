module test_drive_poisson
    use testdrive, only : new_unittest, unittest_type, error_type, check, skip_test
    use mesh_generator, only : calculate_mesh
    use poisson, only : open_file, inp, mxp, mxe, mxb, mxc

    implicit none

    !> inp test inputs
    type :: inp_inputs
        character(len=:), allocatable :: data_filename
        integer :: num_nodes, num_elements, num_boundary_points, num_sets, num_dirichlet_boundary_conditions, &
                   num_neumann_boundary_conditions
    end type inp_inputs

    !> inp test expected outputs
    type :: inp_expected_outputs
        integer :: element_to_node(3,mxp), vb_index(mxe), boundary_node_num(2,mxb), &
                   num_side_nodes(4,mxb)
        real    :: vb(3,mxc), vb1(mxc), vb2(mxc), coordinates(2, mxp)
    end type inp_expected_outputs

contains

    !> Collect all test in this module into a single test suite
    !! 
    !! @param testsuite - An array of unittest_types in which to store this suite's tests
    subroutine collect_poisson_testsuite(testsuite)
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("test_inp_10_05", test_inp_10_05) &
            ]
    end subroutine collect_poisson_testsuite

    !> A test for the inp subroutine with box_size = 10 and edge_size = 5
    subroutine test_inp_10_05(error)
        implicit none
        type(error_type), allocatable, intent(out) :: error

        type(inp_inputs) :: inputs
        type(inp_expected_outputs) :: expected_outputs

        integer :: actual_element_to_node(3,mxp), actual_vb_index(mxe), actual_boundary_node_num(2,mxb), &
                   actual_num_side_nodes(4,mxb), file_io = 123, i, j
        real    :: actual_vb(3,mxc), actual_vb1(mxc), actual_vb2(mxc), actual_coordinates(2, mxp)
        character(len=100) :: data_filename = "testing/data/square_mesh_10_5"
        character(len=200) :: failure_message
        real :: threshold = 1e-06

        !> box_size = 10, edge_size = 5.0
        inputs%num_nodes = 9
        inputs%num_elements = 8
        inputs%num_boundary_points = 8
        inputs%num_sets = 1
        inputs%num_dirichlet_boundary_conditions = 1
        inputs%num_neumann_boundary_conditions = 0

        allocate(character(len(trim(data_filename))) :: inputs%data_filename)
        inputs%data_filename = trim(data_filename)

        expected_outputs%element_to_node(1,1:inputs%num_elements) = [1, 2, 1, 2, 4, 5, 4, 5]
        expected_outputs%element_to_node(2,1:inputs%num_elements) = [2, 3, 5, 6, 5, 6, 8, 9]
        expected_outputs%element_to_node(3,1:inputs%num_elements) = [5, 6, 4, 5, 8, 9, 7, 8]
        expected_outputs%vb_index(1:inputs%num_elements) = [1, 1, 1, 1, 1, 1, 1, 1]
        expected_outputs%boundary_node_num(1,1:inputs%num_boundary_points) = [1, 2, 3, 4, 5, 6, 7, 8]
        expected_outputs%boundary_node_num(2,1:inputs%num_boundary_points) = [1, 1, 1, 1, 1, 1, 1, 1]
        expected_outputs%num_side_nodes(1,1:inputs%num_boundary_points) = [1, 2, 3, 6, 9, 8, 7, 4]
        expected_outputs%num_side_nodes(2,1:inputs%num_boundary_points) = [2, 3, 6, 9, 8, 7, 4, 1]
        expected_outputs%num_side_nodes(3,1:inputs%num_boundary_points) = [1, 2, 2, 6, 8, 7, 7, 3]
        expected_outputs%num_side_nodes(4,1:inputs%num_boundary_points) = [0, 0, 0, 0, 0, 0, 0, 0]
        expected_outputs%vb(1:3,inputs%num_sets) = [1, 1, 1]
        expected_outputs%vb1(inputs%num_dirichlet_boundary_conditions) = 0
        expected_outputs%coordinates(1,1:inputs%num_nodes) = [1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0]
        expected_outputs%coordinates(2,1:inputs%num_nodes) = [1.0, 2.0, 3.0, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0]

        ! Open the file ready to be read
        call open_file(inputs%data_filename, 'old', file_io)

        call inp(                     &
            actual_element_to_node,   &
            actual_vb_index,          &
            actual_coordinates,       &
            actual_boundary_node_num, &
            actual_num_side_nodes,    &
            actual_vb,                &
            actual_vb1,               &
            actual_vb2,               &
            file_io                   &
        )

        close(file_io)
        deallocate(inputs%data_filename)

        do i = 1, inputs%num_elements
            do j = 1, 3
                write(failure_message,'(a,i1,a,i1,a,i2,a,i2)') "Unexpected value for element_to_node(", j, ",", i, "), got ", actual_element_to_node(j, i), " expected ", expected_outputs%element_to_node(j, i)
                call check(error, expected_outputs%element_to_node(j, i), actual_element_to_node(j, i), failure_message)
                if (allocated(error)) return
            end do 

            write(failure_message,'(a,i1,a,i2,a,i2)') "Unexpected value for vb_index(", i, "), got ", actual_vb_index(i), " expected ", expected_outputs%vb_index(i)
            call check(error, expected_outputs%vb_index(i), actual_vb_index(i), failure_message)
            if (allocated(error)) return
        end do

        do i = 1, inputs%num_nodes
            do j = 1, 2
                write(failure_message,'(a,i1,a,i1,a,f5.2,a,f5.2)') "Unexpected value for coordinates(", j, ",", i, "), got ", actual_coordinates(j, i), " expected ", expected_outputs%coordinates(j, i)
                call check(error, expected_outputs%coordinates(j, i), actual_coordinates(j, i), failure_message, thr=threshold)
                if (allocated(error)) return
            end do 
        end do

        do i = 1, inputs%num_boundary_points
            do j = 1, 2
                write(failure_message,'(a,i1,a,i1,a,i2,a,i2)') "Unexpected value for boundary_node_num(", j, ",", i, "), got ", actual_boundary_node_num(j, i), " expected ", expected_outputs%boundary_node_num(j, i)
                call check(error, expected_outputs%boundary_node_num(j, i), actual_boundary_node_num(j, i), failure_message)
                if (allocated(error)) return
            end do 

            do j = 1, 4
                write(failure_message,'(a,i1,a,i1,a,i2,a,i2)') "Unexpected value for num_side_nodes(", j, ",", i, "), got ", actual_num_side_nodes(j, i), " expected ", expected_outputs%num_side_nodes(j, i)
                call check(error, expected_outputs%num_side_nodes(j, i), actual_num_side_nodes(j, i), failure_message)
                if (allocated(error)) return
            end do
        end do

        do i = 1, inputs%num_sets
            do j = 1, 3
                write(failure_message,'(a,i1,a,i1,a,f5.2,a,f5.2)') "Unexpected value for vb(", j, ",", i, "), got ", actual_vb(j, i), " expected ", expected_outputs%vb(j, i)
                call check(error, expected_outputs%vb(j, i), actual_vb(j, i), failure_message, thr=threshold)
                if (allocated(error)) return
            end do
        end do

        do i = 1, inputs%num_dirichlet_boundary_conditions
            write(failure_message,'(a,i1,a,f5.2,a,f5.2)') "Unexpected value for vb1(", i, "), got ", actual_vb1(i), " expected ", expected_outputs%vb1(i)
            call check(error, expected_outputs%vb1(i), actual_vb1(i), failure_message, thr=threshold)
            if (allocated(error)) return
        end do

        do i = 1, inputs%num_neumann_boundary_conditions
            write(failure_message,'(a,i1,a,f5.2,a,f5.2)') "Unexpected value for vb2(", i, "), got ", actual_vb2(i), " expected ", expected_outputs%vb2(i)
            call check(error, expected_outputs%vb2(i), actual_vb2(i), failure_message, thr=threshold)
            if (allocated(error)) return
        end do
    end subroutine test_inp_10_05
end module