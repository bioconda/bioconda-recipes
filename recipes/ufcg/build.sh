#!/bin/bash

set -x -e

UFCG_JAR="UFCG-latest.jar"
UFCG_BIN="${PREFIX}/bin/ufcg"
UFCG_CFG="ufcg/config"

# Copy JAR to the resource directory
TARGET="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p ${TARGET}
cp ufcg/jar/${UFCG_JAR} ${TARGET}

# Alias JAR
mkdir -p ${PREFIX}/bin
echo "#!/usr/bin/env bash" > ${UFCG_BIN}
echo "java -jar ${TARGET}/${UFCG_JAR} \$@" >> ${UFCG_BIN}
chmod +x ${UFCG_BIN}

# Copy resources
mkdir -p ${PREFIX}/config
cp ${UFCG_CFG}/* ${PREFIX}/config

