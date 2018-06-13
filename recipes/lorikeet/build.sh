#!/bin/sh

mkdir lib_compile/scala-2.11.8
rm -rf lib_compile/scala-2.10.2
for name in scala-compiler.jar scala-library.jar scala-reflect.jar ; do
  wget -O lib_compile/scala-2.11.8/$name  https://github.com/AbeelLab/atk/raw/master/lib_compile/scala-2.11.8/$name
done

ant dist
unzip lorikeet-development.zip lorikeet-development.jar
LORIKEET_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $LORIKEET_DIR
cp lorikeet-development.jar $LORIKEET_DIR/lorikeet-$PKG_VERSION.jar

cat <<END >$LORIKEET_DIR/lorikeet
#!/bin/sh

CONDA_BIN_DIR=`dirname \`which conda\``
JAR_PATH=\$CONDA_BIN_DIR/../share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
java ${JAVA_OPTS:-} -jar \$JAR_PATH/lorikeet-$PKG_VERSION.jar \$*
END
chmod a+x $LORIKEET_DIR/lorikeet
ln -s $LORIKEET_DIR/lorikeet $PREFIX/bin
