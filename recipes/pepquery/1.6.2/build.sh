#!/bin/sh
set -eu -o pipefail

PEPQUERY_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PEPQUERY_DIR
cp -R * $PEPQUERY_DIR
PEPQUERY_JAR=$PEPQUERY_DIR/pepquery*.jar
ln -s $PEPQUERY_JAR $PEPQUERY_DIR/pepquery.jar
cp $RECIPE_DIR/pepquery.sh $PEPQUERY_DIR/pepquery
ln -s $PEPQUERY_DIR/pepquery $PREFIX/bin
