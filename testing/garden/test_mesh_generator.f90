module garden_mesh_generator
    use, intrinsic :: iso_fortran_env
    use mesh_generator, only : calculate_mesh_parameters
    use garden, only: &
            example_t, &
            input_t, &
            integer_input_t, &
            result_t, &
            test_item_t, &
            describe, &
            fail, &
            it
    use mesh_parameters_inout_m, only : mesh_parameters_inout_t
    implicit none
    private
    public :: test_calculate_mesh_parameters, check_calculate_mesh_parameters_valid_inputs

contains
    function test_calculate_mesh_parameters() result(tests)
        implicit none 
        type(test_item_t) :: tests

        tests = describe( &
                "calculate_mesh_parameters", &
                [ it( &
                    "passes with valid inputs", &
                    [ example_t(mesh_parameters_inout_t(10, 1.0, 10, 121, 40, 200)) &
                    ], &
                    check_calculate_mesh_parameters_valid_inputs) &
                ])
    end function

    function check_calculate_mesh_parameters_valid_inputs(input) result(result_)
        use garden, only: result_t, assert_equals
        implicit none

        class(mesh_parameters_inout_t), intent(in) :: input
        type(result_t) :: result_

        integer(kind=int64)  :: actual_num_edges_per_boundary, actual_num_nodes, &
                                actual_num_boundary_nodes, actual_num_elements

        select type (input)
        type is (mesh_parameters_inout_t)
            call calculate_mesh_parameters(input%box_size(), input%edge_size(),      &
                actual_num_edges_per_boundary, actual_num_nodes, &
                actual_num_boundary_nodes, actual_num_elements)

            result_ = &
                assert_equals(actual_num_edges_per_boundary, input%expected_num_edges_per_boundary()).and.&
                assert_equals(actual_num_nodes, input%expected_num_nodes()).and.&
                assert_equals(actual_num_boundary_nodes, input%expected_num_boundary_nodes()).and.&
                assert_equals(actual_num_elements, input%expected_num_elements())
        class default
            result_ = fail("Didn't get mesh_parameters_inout_t")
        end select

    end function

    ! function check_calculate_mesh_parameters_valid_inputs() result(result_)
    !     use garden, only: result_t, assert_equals
    !     implicit none

    !     type(result_t) :: result_

    !     integer(kind=int64)  :: box_size = 10
    !     real(kind=real64)    :: edge_size = 1.0
    !     integer(kind=int64)  :: actual_num_edges_per_boundary, actual_num_nodes, &
    !                             actual_num_boundary_nodes, actual_num_elements

    !     integer(kind=int64)  :: &
    !         expected_num_edges_per_boundary = 10, &
    !         expected_num_nodes = 121, &
    !         expected_num_boundary_nodes = 40, &
    !         expected_num_elements = 200, &
    !         num_edges_per_boundary, & 
    !         num_nodes, & 
    !         num_boundary_nodes, & 
    !         num_elements

    !     call calculate_mesh_parameters(box_size, edge_size,      &
    !             actual_num_edges_per_boundary, actual_num_nodes, &
    !             actual_num_boundary_nodes, actual_num_elements)

    !     result_ = &
    !         assert_equals(actual_num_edges_per_boundary, expected_num_edges_per_boundary).and.&
    !         assert_equals(actual_num_nodes, expected_num_nodes).and.&
    !         assert_equals(actual_num_boundary_nodes, expected_num_boundary_nodes).and.&
    !         assert_equals(actual_num_elements, expected_num_elements)

    ! end function
end module garden_mesh_generator
