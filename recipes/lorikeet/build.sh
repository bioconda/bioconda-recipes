#!/bin/sh

LORIKEET_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir $LORIKEET_DIR
cp lorikeet-$PKG_VERSION.jar $LORIKEET_DIR

cat <<END >$LORIKEET_DIR/lorikeet
#!/bin/sh

JAR_PATH=`dirname \`which conda\``
java ${JAVA_OPTS:-} -jar \$JAR_PATH/lorikeet-${PKG_VERSION}.jar \$*
END
chmod a+x $LORIKEET_DIR/lorikeet
ln -s $LORIKEET_DIR/lorikeet $PREFIX/bin
