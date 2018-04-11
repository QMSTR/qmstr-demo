#!/bin/bash
set -e

source ../../build.inc

BASEDIR="$(dirname "$(readlink -f "$0")")"
echo "BASEDIR: $BASEDIR"

# Use easy mode to create sym link to qmstr-wrapper
newPath=$(qmstr -keep which gcc | head -n 1 | cut -d '=' -f2)
export PATH=$newPath
echo "Path adjusted to enable Quartermaster instrumentation: $PATH"

sed "s#SOURCEDIR#${PWD_DEMOS:-$(pwd)}#" ${BASEDIR}/qmstr.tmpl >  ${BASEDIR}/qmstr.yaml
run_qmstr_master

setup_git_src https://github.com/JabRef/jabref.git master jabref

pushd jabref
git clean -fxd
echo "Applying qmstr plugin to gradle build configuration"
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git am --signoff < ${BASEDIR}/add-qmstr.patch

echo "Waiting for qmstr-master server"
qmstr-cli --cserv ${QMSTR_ADDRESS} wait

echo "Start gradle build"
./gradlew qmstr  --stacktrace

echo "Build finished. Triggering analysis."
qmstr-cli --cserv ${QMSTR_ADDRESS} analyze
echo "Analysis finished. Triggering reporting."
qmstr-cli --cserv ${QMSTR_ADDRESS} report

echo "Build finished. Don't forget to quit the qmstr-master server."