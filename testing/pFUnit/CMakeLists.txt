find_package(PFUNIT REQUIRED)
enable_testing()


# Define test files
set(PROJ_PFUNIT_DIR "${PROJECT_SOURCE_DIR}/testing/pFUnit")

# Filter out the main.f90 files. We can only have one main() function in our tests
set(PROJ_POISSON_SOURCES_EXC_MAIN ${PROJ_POISSON_SOURCES})
set(PROJ_MESH_GENERATOR_SOURCES_EXC_MAIN ${PROJ_MESH_GENERATOR_SOURCES})
list(FILTER PROJ_POISSON_SOURCES_EXC_MAIN EXCLUDE REGEX ".*main.f90")
list(FILTER PROJ_MESH_GENERATOR_SOURCES_EXC_MAIN EXCLUDE REGEX ".*main.f90")

# Create library for src code
add_library (sut STATIC ${PROJ_MESH_GENERATOR_SOURCES_EXC_MAIN})


file(GLOB
  test_srcs
  "${PROJ_PFUNIT_DIR}/*.pf"
)
set(test_mesh_generator_src ${test_srcs})
list(FILTER test_mesh_generator_src INCLUDE REGEX ".*mesh.*")

add_pfunit_ctest (mesh_generator_tests
  TEST_SOURCES ${test_mesh_generator_src}
  LINK_LIBRARIES sut # your application library
  )
