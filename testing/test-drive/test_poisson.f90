module test_drive_poisson
    use testdrive, only : new_unittest, unittest_type, error_type, check, skip_test
    use mesh_generator, only : calculate_mesh
    use poisson, only : open_file, inp, mxp, mxe, mxb, mxc, pcg

    implicit none

    !> Scalar values which define a mesh
    type :: mesh_scalars_t
        integer :: num_nodes, num_elements, num_boundary_points, num_sets, num_dirichlet_boundary_conditions, &
                   num_neumann_boundary_conditions
    end type mesh_scalars_t

    !> Vector values which define a mesh
    type :: mesh_vectors_t
        integer :: element_to_node(3,mxe), vb_index(mxe), boundary_node_num(2,mxb), num_side_nodes(4,mxb)
        real    :: vb(3,mxc), vb1(mxc), vb2(mxc), coordinates(2, mxp)
    end type mesh_vectors_t

    !> inp test inputs
    type :: inp_inputs_t
        character(len=:), allocatable :: data_filename
        type(mesh_scalars_t) :: mesh_scalars
    end type inp_inputs_t

    !> inp test expected outputs
    type :: inp_expected_outputs_t
        type(mesh_vectors_t) :: mesh_vectors
    end type inp_expected_outputs_t

    !> pcg test inputs
    type :: pcg_inputs_t
        character(len=:), allocatable :: data_filename
        type(mesh_scalars_t) :: mesh_scalars
        type(mesh_vectors_t) :: mesh_vectors
    end type pcg_inputs_t

    !> pcg test expected outputs
    type :: pcg_expected_outputs_t
        real :: nodal_value_of_f(mxp)
    end type pcg_expected_outputs_t

contains

    !> Collect all test in this module into a single test suite
    !! 
    !! @param testsuite - An array of unittest_types in which to store this suite's tests
    subroutine collect_poisson_testsuite(testsuite)
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("test_inp_15_05", test_inp_15_05), &
            new_unittest("test_pcg_15_05", test_pcg_15_05)  &
            ]
    end subroutine collect_poisson_testsuite

    !> Define the values of a mesh with box_size = 10 and edge_size = 5
    subroutine get_15_05_mesh_values(data_filename, mesh_scalars, mesh_vectors)
        implicit none
        character(len=:), allocatable :: data_filename
        type(mesh_scalars_t), intent(out) :: mesh_scalars
        type(mesh_vectors_t), intent(out) :: mesh_vectors
        
        character(len=100) :: data_filename_fixed = "testing/data/square_mesh_15_5"

        allocate(character(len(trim(data_filename_fixed))) :: data_filename)
        data_filename = trim(data_filename_fixed)

        mesh_scalars%num_nodes = 16
        mesh_scalars%num_elements = 18
        mesh_scalars%num_boundary_points = 12
        mesh_scalars%num_sets = 1
        mesh_scalars%num_dirichlet_boundary_conditions = 1
        mesh_scalars%num_neumann_boundary_conditions = 0

        mesh_vectors%element_to_node(1,1:mesh_scalars%num_elements) = [1, 2, 3, 1, 2, 3, 5, 6, 7, 5, 6, 7, 9, 10, 11, 9, 10, 11]
        mesh_vectors%element_to_node(2,1:mesh_scalars%num_elements) = [2, 3, 4, 6, 7, 8, 6, 7, 8, 10, 11, 12, 10, 11, 12, 14, 15, 16]
        mesh_vectors%element_to_node(3,1:mesh_scalars%num_elements) = [6, 7, 8, 5, 6, 7, 10, 11, 12, 9, 10, 11, 14, 15, 16, 13, 14, 15]
        mesh_vectors%vb_index(1:mesh_scalars%num_elements) = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        mesh_vectors%boundary_node_num(1,1:mesh_scalars%num_boundary_points) = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        mesh_vectors%boundary_node_num(2,1:mesh_scalars%num_boundary_points) = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        mesh_vectors%num_side_nodes(1,1:mesh_scalars%num_boundary_points) = [1, 2, 3, 4, 8, 12, 16, 15, 14, 13, 9, 5]
        mesh_vectors%num_side_nodes(2,1:mesh_scalars%num_boundary_points) = [2, 3, 4, 8, 12, 16, 15, 14, 13, 9, 5, 1]
        mesh_vectors%num_side_nodes(3,1:mesh_scalars%num_boundary_points) = [1, 2, 3, 3, 9, 15, 18, 17, 16, 16, 10, 4]
        mesh_vectors%num_side_nodes(4,1:mesh_scalars%num_boundary_points) = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

        mesh_vectors%vb(1:3,mesh_scalars%num_sets) = [1, 1, 1]
        mesh_vectors%vb1(1:mesh_scalars%num_dirichlet_boundary_conditions) = 0
        mesh_vectors%vb1(1:mesh_scalars%num_neumann_boundary_conditions) = 0
        mesh_vectors%coordinates(1,1:mesh_scalars%num_nodes) = [1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0, 3.0, 4.0, 4.0, 4.0, 4.0]
        mesh_vectors%coordinates(2,1:mesh_scalars%num_nodes) = [1.0, 2.0, 3.0, 4.0, 1.0, 2.0, 3.0, 4.0, 1.0, 2.0, 3.0, 4.0, 1.0, 2.0, 3.0, 4.0]
    end subroutine get_15_05_mesh_values

    !> Verification code for the inp subroutine
    subroutine verify_inp(error, inputs, expected_outputs)
        implicit none
        type(error_type), allocatable, intent(out) :: error
        type(inp_inputs_t), intent(in)  :: inputs
        type(inp_expected_outputs_t), intent(in)  :: expected_outputs

        integer :: actual_element_to_node(3,mxp), actual_vb_index(mxe), actual_boundary_node_num(2,mxb), &
                   actual_num_side_nodes(4,mxb), file_io = 123, i, j
        real    :: actual_vb(3,mxc), actual_vb1(mxc), actual_vb2(mxc), actual_coordinates(2, mxp)
        character(len=200) :: failure_message
        real :: threshold = 1e-06

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

        do i = 1, inputs%mesh_scalars%num_elements
            do j = 1, 3
                write(failure_message,'(a,i1,a,i1,a,i2,a,i2)') "Unexpected value for element_to_node(", j, ",", i, "), got ", actual_element_to_node(j, i), " expected ", expected_outputs%mesh_vectors%element_to_node(j, i)
                call check(error, actual_element_to_node(j, i), expected_outputs%mesh_vectors%element_to_node(j, i), failure_message)
                if (allocated(error)) return
            end do 

            write(failure_message,'(a,i1,a,i2,a,i2)') "Unexpected value for vb_index(", i, "), got ", actual_vb_index(i), " expected ", expected_outputs%mesh_vectors%vb_index(i)
            call check(error, actual_vb_index(i), expected_outputs%mesh_vectors%vb_index(i), failure_message)
            if (allocated(error)) return
        end do

        do i = 1, inputs%mesh_scalars%num_nodes
            do j = 1, 2
                write(failure_message,'(a,i1,a,i1,a,f5.2,a,f5.2)') "Unexpected value for coordinates(", j, ",", i, "), got ", actual_coordinates(j, i), " expected ", expected_outputs%mesh_vectors%coordinates(j, i)
                call check(error, actual_coordinates(j, i), expected_outputs%mesh_vectors%coordinates(j, i), failure_message, thr=threshold)
                if (allocated(error)) return
            end do 
        end do

        do i = 1, inputs%mesh_scalars%num_boundary_points
            do j = 1, 2
                write(failure_message,'(a,i1,a,i1,a,i2,a,i2)') "Unexpected value for boundary_node_num(", j, ",", i, "), got ", actual_boundary_node_num(j, i), " expected ", expected_outputs%mesh_vectors%boundary_node_num(j, i)
                call check(error, actual_boundary_node_num(j, i), expected_outputs%mesh_vectors%boundary_node_num(j, i), failure_message)
                if (allocated(error)) return
            end do 

            do j = 1, 4
                write(failure_message,'(a,i1,a,i1,a,i2,a,i2)') "Unexpected value for num_side_nodes(", j, ",", i, "), got ", actual_num_side_nodes(j, i), " expected ", expected_outputs%mesh_vectors%num_side_nodes(j, i)
                call check(error, actual_num_side_nodes(j, i), expected_outputs%mesh_vectors%num_side_nodes(j, i), failure_message)
                if (allocated(error)) return
            end do
        end do

        do i = 1, inputs%mesh_scalars%num_sets
            do j = 1, 3
                write(failure_message,'(a,i1,a,i1,a,f5.2,a,f5.2)') "Unexpected value for vb(", j, ",", i, "), got ", actual_vb(j, i), " expected ", expected_outputs%mesh_vectors%vb(j, i)
                call check(error, actual_vb(j, i), expected_outputs%mesh_vectors%vb(j, i), failure_message, thr=threshold)
                if (allocated(error)) return
            end do
        end do

        do i = 1, inputs%mesh_scalars%num_dirichlet_boundary_conditions
            write(failure_message,'(a,i1,a,f5.2,a,f5.2)') "Unexpected value for vb1(", i, "), got ", actual_vb1(i), " expected ", expected_outputs%mesh_vectors%vb1(i)
            call check(error, actual_vb1(i), expected_outputs%mesh_vectors%vb1(i), failure_message, thr=threshold)
            if (allocated(error)) return
        end do

        do i = 1, inputs%mesh_scalars%num_neumann_boundary_conditions
            write(failure_message,'(a,i1,a,f5.2,a,f5.2)') "Unexpected value for vb2(", i, "), got ", actual_vb2(i), " expected ", expected_outputs%mesh_vectors%vb2(i)
            call check(error, actual_vb2(i), expected_outputs%mesh_vectors%vb2(i), failure_message, thr=threshold)
            if (allocated(error)) return
        end do
    end subroutine verify_inp
    !> A test for the inp subroutine with box_size = 10 and edge_size = 5
    subroutine test_inp_15_05(error)
        implicit none
        type(error_type), allocatable, intent(out) :: error

        type(inp_inputs_t) :: inputs
        type(inp_expected_outputs_t) :: expected_outputs

        call get_15_05_mesh_values(inputs%data_filename, inputs%mesh_scalars, expected_outputs%mesh_vectors)

        call verify_inp(error, inputs, expected_outputs)

        deallocate(inputs%data_filename)
    end subroutine test_inp_15_05

    subroutine verify_pcg(error, inputs, expected_outputs)
        implicit none
        type(error_type), allocatable, intent(out) :: error

        type(pcg_inputs_t), intent(in) :: inputs
        type(pcg_expected_outputs_t), intent(in) :: expected_outputs
        
        real :: actual_nodal_value_of_f(mxp)
        character(len=200) :: failure_message
        real :: threshold = 1e-06
        integer :: i

        call pcg(                                  &
            inputs%mesh_vectors%element_to_node,   &
            inputs%mesh_vectors%vb_index,          &
            inputs%mesh_vectors%coordinates,       &
            inputs%mesh_vectors%boundary_node_num, &
            inputs%mesh_vectors%num_side_nodes,    &
            inputs%mesh_vectors%vb,                &
            inputs%mesh_vectors%vb1,               &
            inputs%mesh_vectors%vb2,               &
            actual_nodal_value_of_f                &
        )

        ! verify outputs
        do i = 1, inputs%mesh_scalars%num_nodes
            write(failure_message,'(a,i3,a,f9.7,a,f9.7)') "Unexpected value for coordinates(", i, "), got ", actual_nodal_value_of_f(i), " expected ", expected_outputs%nodal_value_of_f(i)
            call check(error, actual_nodal_value_of_f(i), expected_outputs%nodal_value_of_f(i), failure_message, thr=threshold)
            if (allocated(error)) return
        end do
    end subroutine verify_pcg
    !> A test for the pcg subroutine with box_size = 10 and edge_size = 5
    subroutine test_pcg_15_05(error)
        implicit none

        type(error_type), allocatable, intent(out) :: error

        type(pcg_inputs_t) :: inputs
        type(pcg_expected_outputs_t) :: expected_outputs

        call get_15_05_mesh_values(inputs%data_filename, inputs%mesh_scalars, inputs%mesh_vectors)
        expected_outputs%nodal_value_of_f(1:inputs%mesh_scalars%num_nodes) = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.407407, 0.481481, 0.518518, 0.592592]

        call verify_pcg(error, inputs, expected_outputs)

        deallocate(inputs%data_filename)
    end subroutine test_pcg_15_05
end module