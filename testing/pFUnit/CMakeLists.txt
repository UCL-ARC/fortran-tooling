find_package(PFUNIT REQUIRED)
enable_testing()


# Define test files
set(PROJ_PFUNIT_DIR "${PROJECT_SOURCE_DIR}/testing/pFUnit")

# Filter out the main.f90 files. We can only have one main() function in our tests
set(PROJ_POISSON_SOURCES_EXC_MAIN ${PROJ_POISSON_SOURCES})
set(PROJ_MESH_GENERATOR_SOURCES_EXC_MAIN ${PROJ_MESH_GENERATOR_SOURCES})
list(FILTER PROJ_POISSON_SOURCES_EXC_MAIN EXCLUDE REGEX ".*main.f90")
list(FILTER PROJ_MESH_GENERATOR_SOURCES_EXC_MAIN EXCLUDE REGEX ".*main.f90")

file(GLOB
  test_srcs
  "${PROJ_PFUNIT_DIR}/*.pf"
)
set(test_hello_src ${test_srcs})
list(FILTER test_hello_src INCLUDE REGEX ".*hello.*")


add_pfunit_ctest (hello_tests
  TEST_SOURCES ${test_hello_src}
  )
