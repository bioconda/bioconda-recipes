#!/bin/bash
set -eu

PACKAGE_HOME=$PREFIX/bin

mkdir -p $PACKAGE_HOME

pushd novo2maq
make
cp novo2maq ${PACKAGE_HOME}
popd

find . -maxdepth 1 -perm -111 -type f -exec cp {} ${PACKAGE_HOME} ';'

SOURCE_FILE=$RECIPE_DIR/novoalign-license-register.sh
DEST_FILE=$PACKAGE_HOME/novoalign-license-register

cp "$SOURCE_FILE" "$DEST_FILE"

chmod +x $DEST_FILE

DOC_DIR=${PREFIX}/share/doc/novoalign
mkdir -p ${DOC_DIR}
cp *.pdf *.txt ${RECIPE_DIR}/license.txt ${DOC_DIR}
