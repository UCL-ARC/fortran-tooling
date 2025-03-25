!> This program generates a basic square 2D traingular mesh. The
!> geometry of this mesh is kept simple by placing nodes in a
!> regular pattern, as demonstrated below (note the arrangment
!> of the node and element IDs).
!>```
!> 21._____22._____23._____24._____25.
!>   |     / |     / |     / |     / |
!>   | 29/ 25| 30/ 26| 31/ 27| 32/ 28|
!>   | /     | /     | /     | /     |
!> 16._____17._____18._____19._____20.
!>   |     / |     / |     / |     / |
!>   | 21/ 17| 22/ 18| 23/ 19| 24/ 20|
!>   | /     | /     | /     | /     |
!> 11._____12._____13._____14._____15.
!>   |     / |     / |     / |     / |
!>   | 13/  9| 14/ 10| 15/ 11| 16/ 12|
!>   | /     | /     | /     | /     |
!>  6.______7.______8.______9._____10.
!>   |     / |     / |     / |     / |
!>   |  5/  1|  6/  2|  7/  3|  8/  4|
!>   | /     | /     | /     | /     |
!>  1.______2.______3.______4.______5.
!>```
!> The size of the output square and its elements is determined
!> by two inputs, box_size (the length of each side of the
!> square) and edge_size (the length of a single elements
!> boundary edge). Therefore, the above mesh would be generated
!> by inputs that satisfy - box_size / edge_size = 4.
program generate_mesh
    use, intrinsic :: iso_fortran_env, only : int64, real64
    use mesh_generator, only : calculate_mesh_parameters, calculate_mesh, write_mesh_to_file

    implicit none

    integer                       :: argl
    character(len=:), allocatable :: a
    !> The total length of one side of the box mesh, made up of multiple edges
    integer(kind=int64)           :: box_size
    !> The length of one edge within the box mesh
    real(kind=real64)             :: edge_size

    ! Mesh variables
    integer(kind=int64) :: num_nodes, num_elements, num_boundary_nodes, &
                           num_edges_per_boundary
    integer(kind=int64), dimension(:, :), allocatable :: elements, boundary_edges
    real(kind=real64), dimension(:, :), allocatable :: nodes

    ! Get command line args (Fortran 2003 standard)
    if (command_argument_count() == 2) then
        call get_command_argument(1, length=argl)
        allocate(character(argl) :: a)
        call get_command_argument(1, a)
        read(a,*) box_size
        deallocate(a)
        call get_command_argument(2, length=argl)
        allocate(character(argl) :: a)
        call get_command_argument(2, a)
        read(a,*) edge_size
        deallocate(a)
    else
        write(*,'(A)') "Error: Invalid input"
        call get_command_argument(0, length=argl)
        allocate(character(argl) :: a)
        call get_command_argument(0, a)
        write(*,'(A,A,A)') "Usage: ", a, " <box_size> <edge_size>"
        deallocate(a)
        stop
    end if

    ! Output start message
    write(*,'(A)') "Generating mesh using:"
    write(*,'(A,1I16)') " box size: ", box_size
    write(*,'(A,1F16.3)') " edge_size: ", edge_size

    call calculate_mesh_parameters(box_size, edge_size, num_edges_per_boundary, num_nodes, num_boundary_nodes, num_elements)

    ! Allocate arrays
    allocate(nodes(2, num_nodes))
    allocate(elements(3, num_elements))
    allocate(boundary_edges(3, num_boundary_nodes))

    call calculate_mesh(num_edges_per_boundary, num_nodes, num_elements, num_boundary_nodes, nodes, elements, boundary_edges)

    call write_mesh_to_file(num_nodes, num_elements, num_boundary_nodes, nodes, elements, boundary_edges)
end program generate_mesh
