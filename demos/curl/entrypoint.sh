#!/bin/bash
set -e

trap cleanup_master EXIT

DEMOWD="$(dirname "$(readlink -f "$0")")"

echo "####################"
echo "Running cURL demo"
echo "####################"

source ${DEMOWD}/../../build.inc

echo "DEMOWD: $DEMOWD"
# Use easy mode to create sym link to qmstr-wrapper
newPath=$(qmstr -keep which gcc | head -n 1 | cut -d '=' -f2)
export PATH=$newPath
echo "Path adjusted to enable Quartermaster instrumentation: $PATH"

sed "s#SOURCEDIR#${DEMOWD}#" ${DEMOWD}/qmstr.tmpl > ${DEMOWD}/qmstr.yaml
run_qmstr_master

pushd ${DEMOWD}
setup_git_src https://git.fsfe.org/jonas/curl.git reuse-compliant curl

pushd curl
git clean -fxd
mkdir build
cd build
GCCPATH=$(echo $PATH | cut -d ':' -f1)
echo "GCCPATH: $GCCPATH"
export CC=$GCCPATH/gcc
export CXX=$GCCPATH/g++
export CMAKE_LINKER=gcc

ADDRESS=$(check_qmstr_address)

echo "Waiting for qmstr-master server"
qmstr-cli $ADDRESS wait
echo "master server up and running"

echo "[INFO] Start curl build"
cmake ..
make 

echo "[INFO] Build finished. Triggering analysis."
qmstr-cli $ADDRESS analyze

echo "[INFO] Analysis finished. Triggering reporting."
qmstr-cli $ADDRESS report

echo "Build finished. Don't forget to quit the qmstr-master server."