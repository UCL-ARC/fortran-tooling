#!/bin/bash



clean_build=false
build_cmake=false
build_fpm=false
build_tests=true
PFUNIT_INSTALLED_PATH="" # Path to pFUnit/installed directory
run_tests=false

help() {
  echo "Usage:"
  echo "    -h  Display this help message."
  echo "    -c  Clean all build artifacts."
  echo "    -m  Build via cmake."
  echo "    -f  Build via fpm."
  echo "    -s  Skip building cmake tests"
  echo "    -p  Path to pFUnit/installed directory."
  echo "    -t  Run tests."
  exit 0
}

# check for no input arguments and show help
if [ $# -eq 0 ];
then
    ./build.sh -h
    exit 0
fi

# parse input arguments
while getopts "hcmftp:s" opt
do
  case ${opt} in
    h  ) help;;
    c  ) clean_build=true;;
    m  ) build_cmake=true;;
    f  ) build_fpm=true;;
    s  ) build_tests=false;;
    p  ) PFUNIT_INSTALLED_PATH="${OPTARG}";;
    t  ) run_tests=true;;
    \? ) echo "Invalid option: $OPTARG" >&2; exit 1;;
  esac
done
shift $((OPTIND -1))

if [ "$clean_build" == "true" ]
then
    if [ -d "build" ]; then
        echo "Cleaning fpm build"
        rm -rf build
    fi
    if [ -d "build-cmake" ]; then
        echo "Cleaning cmake build"
        rm -rf build-cmake
    fi
fi

# Build cmake version
if [ "$build_cmake" == "true" ]
then
    echo "Building using cmake"
    if [ "$build_tests" == "true" ]
    then
        echo "Building tests"
        cmake -DCMAKE_PREFIX_PATH="$PFUNIT_INSTALLED_PATH" -DBUILD_TESTS=ON -B build-cmake 
    else
        echo "Skipping tests"
        cmake -DBUILD_TESTS=OFF -B build-cmake 
    fi
    cmake --build build-cmake
fi

# Build fpm version
if [ "$build_fpm" == "true" ]
then
    echo "Building using fpm"
    fpm build
fi

if [ "$run_tests" == "true" ]
then
    tests_run=false
    if [ -d "build-cmake" ]; then
        echo "Running cmake tests"
        tests_run=true
        pushd build-cmake
        ctest
        popd
    fi

    if [ -d "build" ]; then
        echo "Running fpm tests"
        tests_run=true
        fpm test
    fi

    if [ "$tests_run" == "false" ]
    then
        echo "No tests found. Must build first."
    fi
fi
