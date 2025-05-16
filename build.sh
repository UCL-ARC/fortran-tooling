#!/bin/bash

set -e

PFUNIT_REMOTE_URL="https://github.com/Goddard-Fortran-Ecosystem/pFUnit.git"
PFUNIT_INSTALLED_PATH="" # Path to pFUnit/installed directory

clean_build=false
build_cmake=false
build_fpm=false
build_tests=true
run_tests=false
pfunit_src_path=""
pfunit_version="v4.12.0"
clean_build_pfunit=false
num_build_threads="1"

help() {
  echo "Usage:"
  echo "    -h | --help              Display this help message."
  echo "    -c | --clean             Clean all build artifacts."
  echo "    -m | --build-cmake       Build via cmake."
  echo "    -f | --build-fpm         Build via fpm."
  echo "    -p | --pfunit-dir        Absolute path to root dir for pFUnit to be installed."
  echo "    --pfunit-version         The version of pFUnit install."
  echo "    --clean-build-pfunit     Remove existing pFUnit build before rebuilding."
  echo "    -s | --skip-cmake-tests  Skip building and running cmake tests (fpm tests are only built when ran)."
  echo "    -t | --test              Run tests."
  echo "    -n | --num-build-threads The number of threads to use for building. defaults to 1."
  exit 0
}

# check for no input arguments and show help
if [ $# -eq 0 ];
then
    help
    exit 1
fi

# parse input arguments
while [ $# -gt 0 ] ; do
    case $1 in
        -h | --help)
            help
            exit 0
            ;;
        -c | --clean)
            clean_build=true
            shift 1
            continue
            ;;
        -m | --build-cmake)
            build_cmake=true
            shift 1
            continue
            ;;
        -f | --build-fpm)
            build_fpm=true
            shift 1
            continue
            ;;
        -p | --pfunit-dir)
            pfunit_src_path=$2
            PFUNIT_INSTALLED_PATH="$pfunit_src_path/build/installed"
            shift 2
            continue
            ;;
        --pfunit-version)
            pfunit_version=$2
            shift 2
            continue
            ;;
        --clean-build-pfunit)
            clean_build_pfunit=true
            shift 1
            continue
            ;;
        -s | --skip-cmake-tests)
            build_tests=false
            shift 1
            continue
            ;;
        -t | --test)
            run_tests=true
            shift 1
            continue
            ;;
        -n | --num-build-threads)
            num_build_threads=$2
            shift 2
            continue
            ;;
        *) 
            echo "Invalid option: $1" >&2; 
            help 
            exit 1
            ;;
    esac
    shift 1
done

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
    # Build pFUnit
    if [ "$build_tests" == "true" ]
    then
        if [ "$pfunit_src_path" == "" ]
        then
            echo "No root dir for pFUnit provided. These tests will be skipped"
        else    
            if [ -d "$pfunit_src_path" ]
            then
                pushd $pfunit_src_path > /dev/null
                if [ $(git remote get-url origin) != "$PFUNIT_REMOTE_URL" ]
                then
                    echo "pFUnit source path $pfunit_src_path is not a valid pFUnit clone. Please remove the existing clone or choose a different path."
                    exit 1
                fi
                current_pfunit_version=$(git describe --exact-match --tags)
                
                if [ "$current_pfunit_version" != "$pfunit_version" ]
                then
                    echo "pFUnit version $current_pfunit_version found but $pfunit_version was requested. Please switch versions or remove the existing clone."
                    exit 1
                fi
                popd > /dev/null
            else
                mkdir $pfunit_src_path
                pushd $pfunit_src_path > /dev/null
                echo "Cloning pFUnit from $PFUNIT_REMOTE_PATH"
                git clone --branch $pfunit_version $PFUNIT_REMOTE_URL $pfunit_src_path
                popd > /dev/null
                exit 0
            fi

            if [ "$clean_build_pfunit" == "true" ]
            then
                if [ -d "$pfunit_src_path/build" ]
                then
                    echo "Cleaning pFUnit build"
                    rm -rf $pfunit_src_path/build
                fi
            fi

            echo "Building pFUnit from source"
            cmake $pfunit_src_path -B $pfunit_src_path/build
            cmake --build $pfunit_src_path/build "-j$num_build_threads" --target install
        fi
    fi

    echo "Building using cmake"

    TEST_FLAGS=""
    if [ "$build_tests" == "true" ]
    then
        TEST_FLAGS="-DBUILD_TEST_DRIVE=ON"
        if [ "$pfunit_src_path" != "" ]
        then
            TEST_FLAGS="-DCMAKE_PREFIX_PATH=$PFUNIT_INSTALLED_PATH -DBUILD_PFUNIT=ON $TEST_FLAGS"
        fi
    fi

    echo "cmake $TEST_FLAGS -B build-cmake"
    cmake $TEST_FLAGS -B build-cmake
    cmake --build build-cmake "-j$num_build_threads"
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
        pushd build-cmake > /dev/null
        ctest
        popd > /dev/null
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
