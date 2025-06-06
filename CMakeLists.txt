cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

# Set project name
project(
  "fortran-tooling"
  LANGUAGES "Fortran"
  VERSION "0.0.1"
  DESCRIPTION "Fortran tooling"
)

set(GFORTRAN_FLAGS "-ffree-line-length-none")
set(CMAKE_Fortran_FLAGS "${GFORTRAN_FLAGS}") # Update this to match the flags for the chosen compiler

# Define src files
set(PROJ_SRC_DIR "${PROJECT_SOURCE_DIR}/src")
file(GLOB PROJ_MESH_GENERATOR_SOURCES "${PROJ_SRC_DIR}/mesh_generator/*.f90")
file(GLOB PROJ_POISSON_SOURCES "${PROJ_SRC_DIR}/poisson/*.f90")

# Build src executables
add_executable("${PROJECT_NAME}-mesh-generator" "${PROJ_MESH_GENERATOR_SOURCES}")
add_executable("${PROJECT_NAME}-poisson" "${PROJ_POISSON_SOURCES}")

enable_testing()

#--------------------------------------#
#             test-drive               #
#--------------------------------------#
if (BUILD_TESTS MATCHES "ON")
  add_subdirectory("testing/test-drive")
endif()

#--------------------------------------#
#               pFUnit                 #
#--------------------------------------#
if (BUILD_TESTS MATCHES "ON")
  add_subdirectory("testing/pFUnit")
endif()
