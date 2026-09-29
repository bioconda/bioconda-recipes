#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME/target/scala-2.12

#This kind of path editing is necessary for now but will not be needed in a future version of Slacken
sed -i 's%#SPARK_HOME=/local/spark-3.5.3-bin-hadoop3/%SPARK_HOME='"$PREFIX%" slacken.sh
sed -i 's%#SLACKEN_TMP=/tmp%SLACKEN_TMP=${SLACKEN_TMP:-/tmp}%' slacken.sh
sed -i 's#SLACKEN_HOME=${SLACKEN_HOME:-$(dirname -- "$(readlink "${BASH_SOURCE}")")}#SLACKEN_HOME='"$PACKAGE_HOME#" slacken.sh

sed -i 's#SLACKEN_HOME="$(dirname -- "$(readlink -f "${BASH_SOURCE}")")"#SLACKEN_HOME='"$PACKAGE_HOME#" slacken-aws.sh.template


cp log4j.properties slacken.sh $PACKAGE_HOME
cp slacken-aws.sh.template $PACKAGE_HOME/slacken-aws.sh
cp target/scala-2.12/Slacken-assembly-${PKG_VERSION}.jar $PACKAGE_HOME/target/scala-2.12

ln -s $PACKAGE_HOME/slacken.sh $PREFIX/bin
ln -s $PACKAGE_HOME/slacken-aws.sh $PREFIX/bin

