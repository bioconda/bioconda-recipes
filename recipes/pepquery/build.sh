#!/bin/sh

PEPQUERY_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PEPQUERY_DIR
cp -R * $PEPQUERY_DIR

cat <<END >$PEPQUERY_DIR/pepquery
#!/bin/sh

JAR_PATH=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
java ${JAVA_OPTS:-} -jar \$JAR_PATH/pepquery.jar \$*
END
chmod a+x $PEPQUERY_DIR/pepquery
ln -s $PEPQUERY_DIR/pepquery $PREFIX/bin
