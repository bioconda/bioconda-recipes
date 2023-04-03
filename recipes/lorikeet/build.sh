#!/bin/sh

LORIKEET_DIR=$PREFIX/share/$PKG_NAME
mkdir -p $LORIKEET_DIR
cp lorikeet*.jar $LORIKEET_DIR/lorikeet.jar

cat <<END >$LORIKEET_DIR/lorikeet
#!/bin/sh

CONDA_BIN_DIR=`dirname \`which conda\``
JAR_PATH=/opt/anaconda1anaconda2anaconda3/share/$PKG_NAME
java ${JAVA_OPTS:-} -jar \$JAR_PATH/lorikeet.jar \$*
END
chmod a+x $LORIKEET_DIR/lorikeet
ln -s $LORIKEET_DIR/lorikeet $PREFIX/bin
