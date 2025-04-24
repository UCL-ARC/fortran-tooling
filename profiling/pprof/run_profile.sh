#!/bin/bash
set -e

program_executable=""
program_args=""
gperftools_version="2.16"

help() {
  echo "Usage:"
  echo "    -h  Display this help message."
  echo "    -p  Path to program executable to be profiled."
  echo "    -a  Arguments to be passed to program executable."
  echo "    -v  gperftools version. Defaults to 2.16."
  exit 0
}

# check for no input arguments and show help
if [ $# -eq 0 ];
then
    $0 -h
    exit 0
fi

# parse input arguments
while getopts "hp:a:v:" opt
do
  case ${opt} in
    h  ) help;;
    p  ) program_executable=$OPTARG;;
    a  ) program_args=$OPTARG;;
    v  ) gperftools_version=$OPTARG;;
    \? ) echo "Invalid option: $OPTARG" >&2; exit 1;;
  esac
done
shift $((OPTIND -1))

echo "Profiling program: $program_executable $program_args"

program_name=$(basename "$program_executable")
CPUPROFILE="$program_name.prof" DYLD_INSERT_LIBRARIES="/opt/homebrew/Cellar/gperftools/$gperftools_version/lib/libprofiler.dylib" $program_executable $program_args
pprof --text "$program_executable" "$program_name.prof" > "$program_name.txt"
echo "Profiling results: $program_name.txt"