module garden_mesh_generator
    use, intrinsic :: iso_fortran_env
    use mesh_generator, only : calculate_mesh_parameters
    use garden, only: &
            describe, &
            example_t, &
            fail, &
            input_t, &
            it, &
            result_t, &
            test_item_t
    implicit none
    private
    public :: valid_calculate_mesh_parameters_inout_t, test_mesh_generator, check_calculate_mesh_parameters_valid_inputs

    !! @class valid_calculate_mesh_parameters_inout_t
    !!
    !! @brief A class to store the inputs and expected outputs of the calculate_mesh_parameters function
    type, extends(input_t) :: valid_calculate_mesh_parameters_inout_t
        real(kind=real64) :: edge_size
        integer(kind=int64) :: box_size, expected_num_edges_per_boundary, &
                expected_num_nodes, expected_num_boundary_nodes, expected_num_elements
    end type
    interface valid_calculate_mesh_parameters_inout_t
        module procedure valid_calc_params_constructor
    end interface

contains
    pure function valid_calc_params_constructor(edge_size, box_size, expected_num_edges_per_boundary, &
            expected_num_nodes, expected_num_boundary_nodes, expected_num_elements) result(valid_calculate_mesh_parameters_inout)
        real(kind=real64), intent(in) :: edge_size
        integer(kind=int64), intent(in) :: box_size, expected_num_edges_per_boundary, &
                            expected_num_nodes, expected_num_boundary_nodes, expected_num_elements
        type(valid_calculate_mesh_parameters_inout_t) :: valid_calculate_mesh_parameters_inout

        valid_calculate_mesh_parameters_inout%edge_size = edge_size
        valid_calculate_mesh_parameters_inout%box_size = box_size
        valid_calculate_mesh_parameters_inout%expected_num_edges_per_boundary = expected_num_edges_per_boundary
        valid_calculate_mesh_parameters_inout%expected_num_nodes = expected_num_nodes
        valid_calculate_mesh_parameters_inout%expected_num_boundary_nodes = expected_num_boundary_nodes
        valid_calculate_mesh_parameters_inout%expected_num_elements = expected_num_elements
    end function

    function test_mesh_generator() result(tests)
        implicit none 
        type(test_item_t) :: tests

        tests = describe( &
                "mesh_generator", &
                [ it( &
                    "calculate_mesh_parameters passes with valid inputs", &
                    [ example_t(valid_calculate_mesh_parameters_inout_t(1.0_real64, 10_int64, 10_int64, 121_int64, 40_int64, 200_int64)) &
                    , example_t(valid_calculate_mesh_parameters_inout_t(0.2_real64, 5_int64, 25_int64, 676_int64, 100_int64, 1250_int64))  &
                    , example_t(valid_calculate_mesh_parameters_inout_t(3.0_real64, 100_int64, 33_int64, 1156_int64, 132_int64, 2178_int64))  &
                    ], &
                    check_calculate_mesh_parameters_valid_inputs) &
                ])
    end function

    !> A unit test template for the calculate_mesh_parameters subroutine with valid inputs.
    !! 
    !! @param inputs - An instance of the valid_calculate_mesh_parameters_inout_t containing function
    !!                 inputs and expected outputs.
    !!
    !! @returns result_ - The result of the test (pass or fail) of type result_t
    function check_calculate_mesh_parameters_valid_inputs(input) result(result_)
        use garden, only: result_t, assert_equals
        implicit none

        class(input_t), intent(in) :: input
        type(result_t) :: result_

        integer(kind=int64)  :: actual_num_edges_per_boundary, actual_num_nodes, &
                                actual_num_boundary_nodes, actual_num_elements

        select type (input)
        type is (valid_calculate_mesh_parameters_inout_t)
            call calculate_mesh_parameters(input%box_size, input%edge_size,      &
                actual_num_edges_per_boundary, actual_num_nodes, &
                actual_num_boundary_nodes, actual_num_elements)

            result_ = &
                assert_equals(actual_num_edges_per_boundary, input%expected_num_edges_per_boundary).and.&
                assert_equals(actual_num_nodes, input%expected_num_nodes).and.&
                assert_equals(actual_num_boundary_nodes, input%expected_num_boundary_nodes).and.&
                assert_equals(actual_num_elements, input%expected_num_elements)
        class default
            result_ = fail("Didn't get mesh_parameters_inout_t")
        end select

    end function
end module garden_mesh_generator
