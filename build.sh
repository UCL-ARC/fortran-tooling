#!/bin/bash


PFUNIT_INSTALLED_PATH="" # Path to pFUnit/installed directory

clean_build=false
build_cmake=false
build_fpm=false

help() {
  echo "Usage:"
  echo "    -h  Display this help message."
  echo "    -r  Remove all build artifacts."
  echo "    -c  Build via cmake."
  echo "    -f  Build via fpm."
  echo "    -b  Build with all build tools."
  exit 0
}

# check for no input arguments and show help
if [ $# -eq 0 ];
then
    ./build.sh -h
    exit 0
fi

# parse input arguments
while getopts "hrcfb" opt
do
  case ${opt} in
    h  ) help;;
    r  ) clean_build=true;;
    c  ) build_cmake=true;;
    f  ) build_fpm=true;;
    b  ) 
        build_cmake=true
        build_fpm=true;;
    \? ) echo "Invalid option: $OPTARG" >&2; exit 1;;
  esac
done
shift $((OPTIND -1))

if [ "$clean_build" == "true" ]
then
    if [ "$build_cmake" == "true" ]
    then
        echo "Cleaning cmake build"
        rm -rf build-cmake
    fi

    if [ "$build_fpm" == "true" ]
    then
        echo "Cleaning fpm build"
        rm -rf build
    fi

    if [ "$build_cmake" == "false" ] && [ "$build_fpm" == "false" ]
    then
        echo "No build type specified"
    fi
fi

# Build cmake version
if [ "$build_cmake" == "true" ]
then
    echo "Building using cmake"
    cmake -DCMAKE_PREFIX_PATH="$PFUNIT_INSTALLED_PATH" -B build-cmake 
    cmake --build build-cmake
fi

# Build fpm version
if [ "$build_fpm" == "true" ]
then
    if [ "$clean_build" == "true" ]
    then
        echo "Cleaning fpm build"
        rm -rf build
    fi
    echo "Building using fpm"
    fpm build
fi
