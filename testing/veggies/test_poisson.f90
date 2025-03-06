module veggies_poisson
    use poisson, only : open_file, read_input_file, mxp, mxe, mxb, mxc
    use veggies, only: &
            assert_equals, &
            describe, &
            example_t, &
            fail, &
            input_t, &
            it, &
            result_t, &
            test_item_t
    implicit none
    public :: inp_test_data_t, test_poisson, check_inp_valid_inputs

    !! @class inp_test_t
    !!
    !! @brief A class to store the inputs and expected outputs of the read_input_file function
    type, extends(input_t) :: inp_test_data_t
        character(len=:), allocatable :: data_filename
        integer :: expected_num_nodes,                         &
                   expected_num_elements,                      &
                   expected_num_boundary_points,               &
                   expected_num_sets,                          &
                   expected_num_dirichlet_boundary_conditions, &
                   expected_num_neumann_boundary_conditions
        integer :: expected_element_to_node(3,mxp),   &
                   expected_vb_index(mxe),            &
                   expected_boundary_node_num(2,mxb), &
                   expected_num_side_nodes(4,mxb)
        real    :: expected_vb(3,mxc), &
                   expected_vb1(mxc),  &
                   expected_vb2(mxc),  &
                   expected_coordinates(2, mxp)

    end type
    interface inp_test_data_t
        module procedure inp_test_data_constructor
    end interface
contains
    !> The test suite for poisson
    function test_poisson() result(tests)
        implicit none
        type(test_item_t) :: tests
        integer :: num_nodes_10_5,                         &
                   num_elements_10_5,                      &
                   num_boundary_points_10_5,               &
                   num_sets_10_5,                          &
                   num_dirichlet_boundary_conditions_10_5, &
                   num_neumann_boundary_conditions_10_5,   &
                   element_to_node_10_5(3,mxp),            &
                   vb_index_10_5(mxe),                     &
                   boundary_node_num_10_5(2,mxb),          &
                   num_side_nodes_10_5(4,mxb)
        real    :: vb_10_5(3,mxc), &
                   vb1_10_5(mxc),  &
                   vb2_10_5(mxc),  &
                   coordinates_10_5(2, mxp)

        !> box_size = 10, edge_size = 5.0
        num_nodes_10_5 = 9
        num_elements_10_5 = 8
        num_boundary_points_10_5 = 8
        num_sets_10_5 = 1
        num_dirichlet_boundary_conditions_10_5 = 1
        num_neumann_boundary_conditions_10_5 = 0
        element_to_node_10_5(1,1:num_elements_10_5) = [1, 2, 1, 2, 4, 5, 4, 5]
        element_to_node_10_5(2,1:num_elements_10_5) = [2, 3, 5, 6, 5, 6, 8, 9]
        element_to_node_10_5(3,1:num_elements_10_5) = [5, 6, 4, 5, 8, 9, 7, 8]
        vb_index_10_5(1:num_elements_10_5) = [1, 1, 1, 1, 1, 1, 1, 1]
        boundary_node_num_10_5(1,1:num_boundary_points_10_5) = [1, 2, 3, 4, 5, 6, 7, 8]
        boundary_node_num_10_5(2,1:num_boundary_points_10_5) = [1, 1, 1, 1, 1, 1, 1, 1]
        num_side_nodes_10_5(1,1:num_boundary_points_10_5) = [1, 2, 3, 6, 9, 8, 7, 4]
        num_side_nodes_10_5(2,1:num_boundary_points_10_5) = [2, 3, 6, 9, 8, 7, 4, 1]
        num_side_nodes_10_5(3,1:num_boundary_points_10_5) = [1, 2, 2, 6, 8, 7, 7, 3]
        num_side_nodes_10_5(4,1:num_boundary_points_10_5) = [0, 0, 0, 0, 0, 0, 0, 0]
        vb_10_5(1:3,num_sets_10_5) = [1, 1, 1]
        vb1_10_5(num_dirichlet_boundary_conditions_10_5) = 0
        coordinates_10_5(1,1:num_nodes_10_5) = [1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0]
        coordinates_10_5(2,1:num_nodes_10_5) = [1.0, 2.0, 3.0, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0]

        tests = describe( &
                "poisson", &
                [ it( &
                    "read_input_file passes with valid inputs",                                     &
                    [ example_t(inp_test_data_t("testing/data/square_mesh_10_5",        &
                                                num_nodes_10_5,                         &
                                                num_elements_10_5,                      &
                                                num_boundary_points_10_5,               &
                                                num_sets_10_5,                          &
                                                num_dirichlet_boundary_conditions_10_5, &
                                                num_neumann_boundary_conditions_10_5,   &
                                                element_to_node_10_5,                   &
                                                vb_index_10_5,                          &
                                                boundary_node_num_10_5,                 &
                                                num_side_nodes_10_5,                    &
                                                vb_10_5,                                &
                                                vb1_10_5,                               &
                                                vb2_10_5,                               &
                                                coordinates_10_5))                      &
                    ],                                                                  &
                    check_inp_valid_inputs)                                             &
                ])
    end function

    !> A unit test for the read_input_file subroutine with valid inputs.
    !!
    !! @param inputs - An instance of the inp_test_t containing function
    !!                 inputs and expected outputs.
    !!
    !! @returns result_ - The result of the test (pass or fail) of type result_t
    function check_inp_valid_inputs(input) result(result_)
        implicit none

        class(input_t), intent(in) :: input
        type(result_t) :: result_

        integer :: actual_num_nodes, actual_num_elements, actual_num_boundary_points, &
                   actual_element_to_node(3,mxp),   &
                   actual_vb_index(mxe),            &
                   actual_boundary_node_num(2,mxb), &
                   actual_num_side_nodes(4,mxb)
        real    :: actual_vb(3,mxc), &
                   actual_vb1(mxc),  &
                   actual_vb2(mxc),  &
                   actual_coordinates(2, mxp)
        integer :: file_io = 100

        select type (input)
        type is (inp_test_data_t)
            ! Open the file ready to be read
            call open_file(input%data_filename, 'old', file_io)

            call read_input_file(                       &
                actual_num_nodes,           &
                actual_num_elements,        &
                actual_num_boundary_points, &
                actual_element_to_node,     &
                actual_vb_index,            &
                actual_coordinates,         &
                actual_boundary_node_num,   &
                actual_num_side_nodes,      &
                actual_vb,                  &
                actual_vb1,                 &
                actual_vb2,                 &
                file_io                     &
            )

            result_ = &
                assert_equals(input%expected_element_to_node(:, 1:input%expected_num_elements),          &
                              actual_element_to_node(:, 1:input%expected_num_elements)).and.             &
                assert_equals(input%expected_vb_index(1:input%expected_num_elements),                    &
                              actual_vb_index(1:input%expected_num_elements)).and.                       &
                assert_equals(input%expected_coordinates(:, 1:input%expected_num_nodes),                 &
                              actual_coordinates(:, 1:input%expected_num_nodes)).and.                    &
                assert_equals(input%expected_boundary_node_num(:, 1:input%expected_num_boundary_points), &
                              actual_boundary_node_num(:, 1:input%expected_num_boundary_points)).and.    &
                assert_equals(input%expected_num_side_nodes(:, 1:input%expected_num_boundary_points),    &
                              actual_num_side_nodes(:, 1:input%expected_num_boundary_points)).and.       &
                assert_equals(input%expected_vb(:, 1:input%expected_num_sets),                           &
                              actual_vb(:, 1:input%expected_num_sets)).and.                              &
                assert_equals(input%expected_vb1(1:input%expected_num_dirichlet_boundary_conditions),    &
                              actual_vb1(1:input%expected_num_dirichlet_boundary_conditions)).and.       &
                assert_equals(input%expected_vb2(1:input%expected_num_neumann_boundary_conditions),      &
                              actual_vb2(1:input%expected_num_neumann_boundary_conditions))
        class default
            result_ = fail("Didn't get inp_test_data_t")
        end select

    end function

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! Constructors
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    function inp_test_data_constructor(data_filename,                     &
                                       num_nodes,                         &
                                       num_elements,                      &
                                       num_boundary_points,               &
                                       num_sets,                          &
                                       num_dirichlet_boundary_conditions, &
                                       num_neumann_boundary_conditions,   &
                                       element_to_node,                   &
                                       vb_index,                          &
                                       boundary_node_num,                 &
                                       num_side_nodes,                    &
                                       vb,                                &
                                       vb1,                               &
                                       vb2,                               &
                                       coordinates) result(inp_test_data)
        implicit none

        character(len=100), intent(in) :: data_filename
        integer :: num_nodes,                         &
                   num_elements,                      &
                   num_boundary_points,               &
                   num_sets,                          &
                   num_dirichlet_boundary_conditions, &
                   num_neumann_boundary_conditions
        integer, intent(in) ::        &
            element_to_node(3,mxp),   &
            vb_index(mxe),            &
            boundary_node_num(2,mxb), &
            num_side_nodes(4,mxb)
        real, intent(in) :: &
            vb(3,mxc), &
            vb1(mxc),  &
            vb2(mxc),  &
            coordinates(2, mxp)
        type(inp_test_data_t) :: inp_test_data

        allocate(character(len(trim(data_filename))) :: inp_test_data%data_filename)
        inp_test_data%data_filename = trim(data_filename)

        inp_test_data%expected_num_nodes = num_nodes
        inp_test_data%expected_num_elements = num_elements
        inp_test_data%expected_num_boundary_points = num_boundary_points
        inp_test_data%expected_num_dirichlet_boundary_conditions = num_dirichlet_boundary_conditions
        inp_test_data%expected_num_neumann_boundary_conditions = num_neumann_boundary_conditions

        inp_test_data%expected_element_to_node = element_to_node
        inp_test_data%expected_vb_index = vb_index
        inp_test_data%expected_boundary_node_num = boundary_node_num
        inp_test_data%expected_num_side_nodes = num_side_nodes
        inp_test_data%expected_vb = vb
        inp_test_data%expected_vb1 = vb1
        inp_test_data%expected_vb2 = vb2
        inp_test_data%expected_coordinates = coordinates
    end function
end module