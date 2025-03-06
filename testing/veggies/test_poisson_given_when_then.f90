module veggies_poisson_given_when_then
    use veggies, only : &
            assert_equals, &
            fail, &
            given, &
            input_t, &
            result_t, &
            test_item_t, &
            then__, &
            transformation_failure_t, &
            transformed_t, &
            when
    use poisson, only : read_input_file, mxp, mxe, mxb, mxc
    implicit none

    public
    integer :: expected_num_nodes = 9,                         &
               expected_num_elements = 8,                      &
               expected_num_boundary_points = 8,               &
               expected_num_sets = 1,                          &
               expected_num_dirichlet_boundary_conditions = 1

    type, extends(input_t) :: data_file_state_t
        integer :: file_io, iostat
    end type data_file_state_t
    interface data_file_state_t
        module procedure data_file_state_constructor
    end interface data_file_state_t

    type, extends(input_t) :: load_data_file_result_t
        integer :: actual_num_nodes,                &
                   actual_num_elements,             &
                   actual_num_boundary_points,      &
                   actual_element_to_node(3,mxp),   &
                   actual_vb_index(mxe),            &
                   actual_boundary_node_num(2,mxb), &
                   actual_num_side_nodes(4,mxb)
        real :: actual_vb(3,mxc), &
                actual_vb1(mxc),  &
                actual_vb2(mxc),  &
                actual_coordinates(2, mxp)
        integer :: iostat
    end type load_data_file_result_t
contains

    function test_poisson_given_when_then() result(test)
        implicit none
        type(test_item_t) :: test

        character(len=:), allocatable :: file_name
        integer :: file_io, iostat

        test = given( &
                "the data file square_mesh_10_5 exists", &
                data_file_state_t(), &
                [ when( &
                        "the data file is loaded with poisson::read_input_file", &
                        load_data_file, &
                        [ then__("the file will be open", check_file_is_open) &
                        , then__("num_nodes will be as expected", check_num_nodes) &
                        , then__("num_elements will be as expected", check_num_elements) &
                        , then__("num_boundary_points will be as expected", check_num_boundary_points) &
                        , then__("element_to_node will be as expected", check_element_to_node) &
                        , then__("vb_index will be as expected", check_vb_index) &
                        , then__("boundary_node_num will be as expected", check_boundary_node_num) &
                        , then__("num_side_nodes will be as expected", check_num_side_nodes) &
                        , then__("vb will be as expected", check_vb) &
                        , then__("vb1 will be as expected", check_vb1) &
                        ! , then__("vb2 will be as expected", check_vb2) & ! No assertion for vb2 as this should be empty
                        , then__("coordinates will be as expected", check_coordinates) &
                        ]) &
                ])
    end function test_poisson_given_when_then

    function load_data_file(input) result(output)
        implicit none
        class(input_t), intent(in) :: input
        type(transformed_t) :: output

        type(load_data_file_result_t) :: load_data_file_result

        integer :: iostat

        select type (input)
        type is (data_file_state_t)
            ! declare local variables needed to perform transformation
            call read_input_file(                                 &
                load_data_file_result%actual_num_nodes,           &
                load_data_file_result%actual_num_elements,        &
                load_data_file_result%actual_num_boundary_points, &
                load_data_file_result%actual_element_to_node,     &
                load_data_file_result%actual_vb_index,            &
                load_data_file_result%actual_coordinates,         &
                load_data_file_result%actual_boundary_node_num,   &
                load_data_file_result%actual_num_side_nodes,      &
                load_data_file_result%actual_vb,                  &
                load_data_file_result%actual_vb1,                 &
                load_data_file_result%actual_vb2,                 &
                input%file_io                                     &
            )
            load_data_file_result%iostat = input%iostat

            ! do work to perform transformation
            output = transformed_t(load_data_file_result)
        class default
            output = transformed_t(transformation_failure_t(fail( &
                "Didn't get data_file_state_t")))
        end select
    end function load_data_file

    function check_file_is_open(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        select type (input)
        type is (load_data_file_result_t)
            result_ = assert_equals(0, input%iostat)
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function check_file_is_open

    function check_num_nodes(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        select type (input)
        type is (load_data_file_result_t)
            result_ = &
                assert_equals(9, input%actual_num_nodes)
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function

    function check_num_elements(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        select type (input)
        type is (load_data_file_result_t)
            result_ = &
                assert_equals(8, input%actual_num_elements)
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function

    function check_num_boundary_points(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        select type (input)
        type is (load_data_file_result_t)
            result_ = &
                assert_equals(8, input%actual_num_boundary_points)
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function

    function check_element_to_node(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        select type (input)
        type is (load_data_file_result_t)
            result_ = &
                assert_equals([1, 2, 1, 2, 4, 5, 4, 5], input%actual_element_to_node(1,1:expected_num_elements)).and.&
                assert_equals([2, 3, 5, 6, 5, 6, 8, 9], input%actual_element_to_node(2,1:expected_num_elements)).and.&
                assert_equals([5, 6, 4, 5, 8, 9, 7, 8], input%actual_element_to_node(3,1:expected_num_elements))
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function check_element_to_node

    function check_vb_index(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        select type (input)
        type is (load_data_file_result_t)
            result_ = assert_equals([1, 1, 1, 1, 1, 1, 1, 1], input%actual_vb_index(1:expected_num_elements))
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function check_vb_index

    function check_boundary_node_num(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        select type (input)
        type is (load_data_file_result_t)
            result_ = &
                assert_equals([1, 2, 3, 4, 5, 6, 7, 8], input%actual_boundary_node_num(1,1:expected_num_boundary_points)).and.&
                assert_equals([1, 1, 1, 1, 1, 1, 1, 1], input%actual_boundary_node_num(2,1:expected_num_boundary_points))
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function check_boundary_node_num

    function check_num_side_nodes(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        select type (input)
        type is (load_data_file_result_t)
            result_ = &
                assert_equals([1, 2, 3, 6, 9, 8, 7, 4], input%actual_num_side_nodes(1,1:expected_num_boundary_points)).and.&
                assert_equals([2, 3, 6, 9, 8, 7, 4, 1], input%actual_num_side_nodes(2,1:expected_num_boundary_points)).and.&
                assert_equals([1, 2, 2, 6, 8, 7, 7, 3], input%actual_num_side_nodes(3,1:expected_num_boundary_points)).and.&
                assert_equals([0, 0, 0, 0, 0, 0, 0, 0], input%actual_num_side_nodes(4,1:expected_num_boundary_points))
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function check_num_side_nodes

    function check_vb(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        real :: expected_vb(3,expected_num_sets)
        expected_vb(1:3, expected_num_sets) = [1, 1, 1]

        select type (input)
        type is (load_data_file_result_t)
            result_ = assert_equals(expected_vb(:,:), input%actual_vb(:,1:expected_num_sets))
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function check_vb

    function check_vb1(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        select type (input)
        type is (load_data_file_result_t)
            result_ = assert_equals([0.0], input%actual_vb1(1:expected_num_dirichlet_boundary_conditions))
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function check_vb1

    function check_coordinates(input) result(result_)
        implicit none
        class(input_t), intent(in) :: input
        type(result_t) :: result_

        select type (input)
        type is (load_data_file_result_t)
            result_ = &
                assert_equals([1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0],          &
                              input%actual_coordinates(1, 1:expected_num_nodes)).and. &
                assert_equals([1.0, 2.0, 3.0, 1.0, 2.0, 3.0, 1.0, 2.0, 3.0],          &
                              input%actual_coordinates(2, 1:expected_num_nodes))
        class default
            result_ = fail("Didn't get load_data_file_result_t")
        end select
    end function check_coordinates

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! Constructors
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    function data_file_state_constructor() result(data_file_state)
        implicit none
        type(data_file_state_t) :: data_file_state

        integer, parameter :: file_io = 200
        integer :: iostat

        open(unit=file_io,   &
             file="testing/data/square_mesh_10_5", &
             status="old",   &
             IOSTAT=iostat)

        data_file_state%file_io = file_io
        data_file_state%iostat = iostat
    end function data_file_state_constructor
end module veggies_poisson_given_when_then