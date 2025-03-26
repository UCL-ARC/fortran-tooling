!> This module contians proceducers for generating a basic square 2D triangular-mesh. 
!> |mesh_geometry_description|
module mesh_generator
    use, intrinsic :: iso_fortran_env, only : int64, real64
    implicit none
    public

contains

    !> This subroutine calculates the parameters which define the mesh but does not actually
    !> populate the mesh arrays
    subroutine calculate_mesh_parameters(box_size, edge_size, num_edges_per_boundary, num_nodes, num_boundary_nodes, num_elements)
        implicit none
        ! Arguments
        !> The total length of one side of the box mesh, made up of multiple edges
        integer(kind=int64), intent(in)  :: box_size
        !> The length of one edge within the box mesh
        real(kind=real64), intent(in)    :: edge_size
        !> The number of edges along one side of the box
        integer(kind=int64), intent(out) :: num_edges_per_boundary
        !> The total number of nodes in the mesh
        integer(kind=int64), intent(out) :: num_nodes
        !> The total number of nodes on the boundary of the mesh    
        integer(kind=int64), intent(out) :: num_boundary_nodes
        !> The total number of elements in the mesh
        integer(kind=int64), intent(out) :: num_elements

        num_edges_per_boundary = floor(box_size / edge_size)
        num_nodes = (num_edges_per_boundary + 1)**2
        num_boundary_nodes = (num_edges_per_boundary) * 4
        num_elements = 2 * (num_edges_per_boundary)**2
    end subroutine calculate_mesh_parameters

    !> This subroutine takes the generated mesh parameters and populates the mesh arrays with the
    !> elements, boundary edges and nodes of the mesh
    subroutine calculate_mesh(num_edges_per_boundary, num_nodes, num_elements, num_boundary_nodes, nodes, elements, boundary_edges)
        implicit none
        !> The number of edges along one side of the box
        integer(kind=int64), intent(in) :: num_edges_per_boundary
        !> The total number of nodes in the mesh
        integer(kind=int64), intent(in) :: num_nodes
        !> The total number of nodes on the boundary of the mesh
        integer(kind=int64), intent(in) :: num_boundary_nodes
        !> The total number of elements in the mesh
        integer(kind=int64), intent(in) :: num_elements
        !> The array of boundary edges in the mesh
        integer(kind=int64), dimension(3, num_boundary_nodes), intent(inout) :: boundary_edges
        !> The array of elements in the mesh
        integer(kind=int64), dimension(3, num_elements), intent(inout) :: elements
        !> The array of nodes in the mesh
        real(kind=real64), dimension(2, num_nodes), intent(inout) :: nodes

        integer :: num_nodes_per_boundary, bottom_left_node, counter, i, j

        num_nodes_per_boundary = num_edges_per_boundary + 1

        counter = 1
        do i = 1, num_nodes_per_boundary
            do j = 1, num_nodes_per_boundary
                nodes(1, counter) = i ! x coordinate
                nodes(2, counter) = j ! y coordinate
                counter = counter + 1
            end do
        end do

        counter = 1
        do i = 1, num_edges_per_boundary
            do j = 1, num_edges_per_boundary
                bottom_left_node = j + (i - 1) * num_nodes_per_boundary

                elements(1, counter) = bottom_left_node                              ! bottom left node
                elements(2, counter) = bottom_left_node + 1                          ! Next node anti-clockwise
                elements(3, counter) = bottom_left_node + 1 + num_nodes_per_boundary ! Next node anti-clockwise

                elements(1, counter + num_edges_per_boundary) = bottom_left_node
                elements(2, counter + num_edges_per_boundary) = bottom_left_node + num_nodes_per_boundary + 1
                elements(3, counter + num_edges_per_boundary) = bottom_left_node + num_nodes_per_boundary

                counter = counter + 1
            end do
            counter = counter + num_edges_per_boundary
        end do

        ! If we are along the bottom boundary
        do i = 1, num_edges_per_boundary
            ! bottom boundary
            boundary_edges(1, i) = i       ! left node
            boundary_edges(2, i) = i + 1   ! right node
            boundary_edges(3, i) = i       ! element

            ! right boundary
            boundary_edges(1, i + num_edges_per_boundary) = i       * num_nodes_per_boundary
            boundary_edges(2, i + num_edges_per_boundary) = (i + 1) * num_nodes_per_boundary
            boundary_edges(3, i + num_edges_per_boundary) = (2*i - 1) * num_edges_per_boundary

            ! top boundary
            boundary_edges(1, i + num_edges_per_boundary * 2) = num_nodes - i + 1
            boundary_edges(2, i + num_edges_per_boundary * 2) = num_nodes - i
            boundary_edges(3, i + num_edges_per_boundary * 2) = num_elements - i + 1

            ! left boundary
            boundary_edges(1, i + num_edges_per_boundary * 3) = (num_nodes_per_boundary - i) * num_nodes_per_boundary + 1
            boundary_edges(2, i + num_edges_per_boundary * 3) = (num_nodes_per_boundary - 1 - i) * num_nodes_per_boundary + 1
            boundary_edges(3, i + num_edges_per_boundary * 3) = num_elements - (num_edges_per_boundary - 1) - (2 * (i - 1) &
                                                                * num_edges_per_boundary)
        end do

    end subroutine calculate_mesh

    !> This subroutine writes the generated mesh parameters and arrays to a file in the format
    !> expected by the Poisson solver
    subroutine write_mesh_to_file(num_nodes, num_elements, num_boundary_nodes, nodes, elements, boundary_edges)
        implicit none
        !> The total number of nodes in the mesh
        integer(kind=int64), intent(in) :: num_nodes
        !> The total number of elements in the mesh
        integer(kind=int64), intent(in) :: num_elements
        !> The total number of nodes on the boundary of the mesh
        integer(kind=int64), intent(in) :: num_boundary_nodes
        !> The array of boundary edges in the mesh
        integer(kind=int64), dimension(3, num_boundary_nodes), intent(inout) :: boundary_edges
        !> The array of elements in the mesh
        integer(kind=int64), dimension(3, num_elements), intent(inout) :: elements
        !> The array of nodes in the mesh
        real(kind=real64), dimension(2, num_nodes), intent(inout) :: nodes

        character(len=11) :: file_name
        integer :: file_io
        integer :: iostat
        integer :: i, num_sets, num_dirichlet_boundary_conditions, num_neumann_boundary_conditions

        ! Baked in defaults
        num_sets = 1
        num_dirichlet_boundary_conditions = 1
        num_neumann_boundary_conditions = 0

        file_name = "square_mesh"
        file_io = 100

        ! Write outpout
        open (unit=file_io, &
        file=file_name,     &
        status="replace",   &
        IOSTAT=iostat)

        if( iostat /= 0) then
            write(*,'(a)') ' *** Error when opening '//trim(file_name)
            stop
        end if

        write(file_io,*) "! num_nodes, num_elements, num_boundary_points, num_sets, num_dirichlet_boundary_conditions, ", &
                         "num_neumann_boundary_conditions"
        write(file_io,*) num_nodes, num_elements, num_boundary_nodes, num_sets, num_dirichlet_boundary_conditions, &
                          num_neumann_boundary_conditions

        write(file_io,*) "! jb,vb(1,jb),vb(2,jb),vb(3,jb) - as many lines as num_sets"
        write(file_io,*) 1, 1, 1, 1

        write(file_io,*) "! jb,vb1(jb) - as many lines as num_dirichlet_boundary_conditions"
        write(file_io,*) 1, 0

        write(file_io,*) "! jb,vb2(jb) - as many lines as num_neumann_boundary_conditions"

        write(file_io,*) "! jp,coordinates(1,jp),coordinates(2,jp) - as many lines as num_nodes"
        do i = 1, num_nodes
            write(file_io,*) i, nodes(1, i), nodes(2, i)
        end do

        write(file_io,*) "! je,element_to_node(1,je),element_to_node(2,je),element_to_node(3,je),vb_index(je) - as many lines ", &
                         "as num_elements"
        do i = 1, num_elements
            write(file_io,*) i, elements(1, i), elements(2, i), elements(3, i), 1
        end do

        write(file_io,*) "! boundary_node_num(1,ib),boundary_node_num(2,ib) - as many lines as num_boundary_points"
        do i = 1, num_boundary_nodes
            write(file_io,*) i, 1
        end do

        write(file_io,*) "! num_side_nodes(1,ib),num_side_nodes(2,ib),num_side_nodes(3,ib),num_side_nodes(4,ib) - as many ", &
                         "lines as num_boundary_points"
        do i = 1, num_boundary_nodes
            write(file_io,*) boundary_edges(1, i), boundary_edges(2, i), boundary_edges(3, i), 0
        end do

        close (unit=file_io, &
        IOSTAT=iostat)

        if( iostat /= 0) then
            write(*,'(a)') ' *** Error when closing '//trim(file_name)
            stop
        end if

    end subroutine write_mesh_to_file

end module mesh_generator
