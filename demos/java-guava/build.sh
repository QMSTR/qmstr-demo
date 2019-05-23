#!/bin/bash
set -e

echo "######################"
echo "# Running Guava demo #"
echo "######################"

if [ "$(uname -s)" = 'Linux' ]; then
DEMOWD="$(dirname "$(readlink -f "$0")")"
else
DEMOWD="$(dirname "$(greadlink -f "$0")")"
fi

source ${DEMOWD}/../../build.inc
pushd ${DEMOWD}
setup_git_src https://github.com/google/guava.git v27.1 guava

pushd guava
git clean -fxd
echo "Applying qmstr plugin to pom"
git am < ${DEMOWD}/0001-Apply-qmstr-plugin.patch
popd

echo "Waiting for qmstr-master server"
eval $(qmstrctl start --wait --verbose)

#qmstrctl create package:jabref --version $(cd jabref && git describe --tags --dirty --long)

echo "[INFO] Start gradle build"
#qmstrctl spawn qmstr/java-jabrefdemo ./gradlew qmstr
cd guava
mvn package -X

#qmstrctl connect package:jabref file:$(find jabref -name "JabRef-?.?-dev.jar") 

echo "[INFO] Build finished. Creating snapshot and triggering analysis."
qmstrctl snapshot -O postbuild-snapshot.tar -f
qmstrctl analyze --verbose

echo "[INFO] Analysis finished. Creating snapshot and triggering reporting."
qmstrctl snapshot -O postanalysis-snapshot.tar -f
qmstrctl report --verbose

qmstrctl quit

echo "[INFO] Build finished."
