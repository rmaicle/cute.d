#!/usr/bin/env bash

#
# Driver for compiling test examples using the SUT module.
#
# $ ../compile test.d
#

declare -r SCRIPT_NAME=${0##*/}
declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
declare -r CURRENT_DIR=$(pwd)



flag_compiler_dmd=1
flag_compiler_ldc=0
# flag_build_debug=1

declare v_compiler="dmd"
declare v_param_build="-debug"
declare v_param_version_str="sut"



# Define the short and long options
OPTIONS_SHORT="d"
OPTIONS_LONG=""
OPTIONS_LONG+="debug"
OPTIONS_LONG+=",dmd"
OPTIONS_LONG+=",ldc"
OPTIONS_LONG+=",no-sut"
OPTIONS_LONG+=",release"
OPTIONS_TEMP=$(getopt               \
    --options ${OPTIONS_SHORT}      \
    --longoptions ${OPTIONS_LONG}   \
    --name "${SCRIPT_NAME}" -- "$@")
# Append unrecognized arguments after --
eval set -- "${OPTIONS_TEMP}"



while true; do
    case "${1}" in
        -d|--debug)             v_param_build="-debug" ; shift ;;
        --dmd)                  v_compiler="dmd" ; shift ;;
        --ldc)                  v_compiler="ldmd2" ; shift ;;
        --no-sut)               v_param_version_str="" ; shift ;;
        --release)              v_param_build="-release" ; shift ;;
        --)                     shift ; break ;;
        *)                      echo "Internal error! $@" ; exit 1 ;;
    esac
done



if [[ -z "${v_param_version_str}" ]]; then
    ${v_compiler}               \
        -I=${SCRIPT_DIR}/..     \
        -I=${CURRENT_DIR}       \
        -i                      \
        -main                   \
        ${v_param_build}        \
        -unittest               \
        -debug=verbose          \
        -run $@
else
    ${v_compiler}               \
        -I=${SCRIPT_DIR}/..     \
        -I=${CURRENT_DIR}       \
        -i                      \
        -main                   \
        ${v_param_build}        \
        -unittest               \
        -version=sut            \
        -debug=verbose          \
        -run $@
fi
