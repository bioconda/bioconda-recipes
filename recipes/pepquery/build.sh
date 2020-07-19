#!/bin/sh

PEPQUERY_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PEPQUERY_DIR
cp -R * $PEPQUERY_DIR
PEPQUERY_JAR=$PEPQUERY_DIR/pepquery*.jar
cat <<END >$PEPQUERY_DIR/pepquery
#!/bin/sh

JAR_PATH=$PEPQUERY_DIR
java ${JAVA_OPTS:-} -jar $PEPQUERY_JAR \$*
END
chmod a+x $PEPQUERY_DIR/pepquery
ln -s $PEPQUERY_DIR/pepquery $PREFIX/bin
