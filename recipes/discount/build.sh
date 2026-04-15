#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME
mkdir -p $PACKAGE_HOME/target/scala-2.12

#This kind of path editing is necessary for now but will not be needed in a future version of Discount
sed -i 's#/path/to/spark-x.x.x-hadoop#'"$PREFIX#" discount.sh
sed -i 's#/set/spark/dir#'"$PREFIX#" discount-shell.sh

sed -i 's#DISCOUNT_HOME="$(dirname -- "$(readlink "${BASH_SOURCE}")")"#DISCOUNT_HOME='"$PACKAGE_HOME#" discount.sh
sed -i 's#DISCOUNT_HOME="$(dirname -- "$(readlink "${BASH_SOURCE}")")"#DISCOUNT_HOME='"$PACKAGE_HOME#" discount-shell.sh
sed -i 's#DISCOUNT_HOME="$(dirname -- "$(readlink "${BASH_SOURCE}")")"#DISCOUNT_HOME='"$PACKAGE_HOME#" discount-aws.sh
sed -i 's#DISCOUNT_HOME="$(dirname -- "$(readlink "${BASH_SOURCE}")")"#DISCOUNT_HOME='"$PACKAGE_HOME#" discount-gcloud.sh

cp log4j.properties discount.sh discount-gcloud.sh discount-aws.sh discount-shell.sh $PACKAGE_HOME
cp target/scala-2.12/Discount-assembly-${PKG_VERSION}.jar $PACKAGE_HOME/target/scala-2.12

ln -s $PACKAGE_HOME/discount.sh $PREFIX/bin
ln -s $PACKAGE_HOME/discount-gcloud.sh $PREFIX/bin
ln -s $PACKAGE_HOME/discount-aws.sh $PREFIX/bin
ln -s $PACKAGE_HOME/discount-shell.sh $PREFIX/bin

