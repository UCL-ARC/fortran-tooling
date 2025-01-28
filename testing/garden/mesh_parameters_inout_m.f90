module mesh_parameters_inout_m
    use, intrinsic :: iso_fortran_env
    use garden, only: input_t

    implicit none
    private
    public :: mesh_parameters_inout_t

    type, extends(input_t) :: mesh_parameters_inout_t
        private
        real(kind=real64) :: edge_size_
        integer(kind=int64) :: box_size_, expected_num_edges_per_boundary_, &
                expected_num_nodes_, expected_num_boundary_nodes_, expected_num_elements_
    contains
        private
        procedure, public :: edge_size, box_size, expected_num_edges_per_boundary, &
                expected_num_nodes, expected_num_boundary_nodes, expected_num_elements
    end type

    interface mesh_parameters_inout_t
        module procedure constructor
    end interface
contains
    pure function constructor(box_size, edge_size, expected_num_edges_per_boundary, &
            expected_num_nodes, expected_num_boundary_nodes, expected_num_elements) result(mesh_parameters_inout)
        real(kind=real64), intent(in) :: edge_size
        integer(kind=int64), intent(in) :: box_size, expected_num_edges_per_boundary, &
                            expected_num_nodes, expected_num_boundary_nodes, expected_num_elements
        type(mesh_parameters_inout_t) :: mesh_parameters_inout

        mesh_parameters_inout%box_size_ = box_size
        mesh_parameters_inout%edge_size_ = edge_size
        mesh_parameters_inout%expected_num_edges_per_boundary_ = expected_num_edges_per_boundary
        mesh_parameters_inout%expected_num_nodes_ = expected_num_nodes
        mesh_parameters_inout%expected_num_boundary_nodes_ = expected_num_boundary_nodes
        mesh_parameters_inout%expected_num_elements_ = expected_num_elements
    end function

    pure function edge_size(self)
        class(mesh_parameters_inout_t), intent(in) :: self
        real(kind=real64) :: edge_size

        edge_size = self%edge_size_
    end function

    pure function box_size(self)
        class(mesh_parameters_inout_t), intent(in) :: self
        integer(kind=int64) :: box_size

        box_size = self%box_size_
    end function

    pure function expected_num_edges_per_boundary(self)
        class(mesh_parameters_inout_t), intent(in) :: self
        integer(kind=int64) :: expected_num_edges_per_boundary

        expected_num_edges_per_boundary = self%expected_num_edges_per_boundary_
    end function

    pure function expected_num_nodes(self)
        class(mesh_parameters_inout_t), intent(in) :: self
        integer(kind=int64) :: expected_num_nodes

        expected_num_nodes = self%expected_num_nodes_
    end function

    pure function expected_num_boundary_nodes(self)
        class(mesh_parameters_inout_t), intent(in) :: self
        integer(kind=int64) :: expected_num_boundary_nodes

        expected_num_boundary_nodes = self%expected_num_boundary_nodes_
    end function

    pure function expected_num_elements(self)
        class(mesh_parameters_inout_t), intent(in) :: self
        integer(kind=int64) :: expected_num_elements

        expected_num_elements = self%expected_num_elements_
    end function
end module mesh_parameters_inout_m