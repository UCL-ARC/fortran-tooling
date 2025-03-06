program main
    use poisson, only : read_input, write_output, pcg, open_file, mxp, mxe, mxb, mxc

    implicit none

    integer       :: boundary_index(mxp), element_to_node(3,mxe),    &
                     vb_index(mxe), boundary_node_num(2,mxb), num_side_nodes(4,mxb)
    real          :: coordinates(2, mxp), nodal_value_of_f(mxp), rhs_vector(mxp), beta(mxp), f_increment(mxp), &
                     vb1(mxc), vb2(mxc), vb(3,mxc), element_stiffness(6,mxe),             &
                     pre_conditioning_matrix(mxp)
    integer       :: fname_io = 100, fname_out_io = 101

    !! CLI inputs
    integer                       :: argl
    character(len=:), allocatable :: a, input_fname, output_fname

    !!
    !! *** Check for input from user
    !!
    if (command_argument_count() == 1) then
        call get_command_argument(1, length=argl)
        allocate(character(argl) :: input_fname)
        call get_command_argument(1, input_fname)
        allocate(character(argl + 4) :: output_fname)
        output_fname = input_fname//'.out'
    else
        write(*,'(A)') "Error: Invalid input"
        call get_command_argument(0, length=argl)
        allocate(character(argl) :: a)
        call get_command_argument(0, a)
        write(*,'(A,A,A)') "Usage: ", a, " <mesh_file_name>"
        deallocate(a)
        stop
    end if

    call open_file(input_fname, 'old', fname_io)
    call open_file(output_fname, 'new', fname_out_io)


    !!
    !! *** Reads the triangular mesh and problem constants: Kx,Ky,Q,fp,q
    !!
    call read_input(element_to_node,vb_index,coordinates,boundary_node_num,num_side_nodes,vb,vb1,vb2,fname_io)

    !!
    !! *** Assembles and solves the system of equations
    !!
    call pcg(element_to_node,vb_index,coordinates,nodal_value_of_f,boundary_node_num,num_side_nodes,vb,vb1,vb2,element_stiffness, &
             rhs_vector,beta,f_increment,boundary_index,pre_conditioning_matrix)

    !!
    !! *** Writes the computed solution
    !!
    call write_output(element_to_node,coordinates,nodal_value_of_f,fname_out_io)
end program main
