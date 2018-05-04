#!/bin/sh

cp lorikeet-$PKG_VERSION.jar ${PREFIX}/bin

cat <<END >${PREFIX}/bin/lorikeet
#!/bin/sh

JAR_PATH=`dirname \`which conda\``
java ${JAVA_OPTS:-} -jar \$JAR_PATH/lorikeet-${PKG_VERSION}.jar \$*
END
chmod a+x ${PREFIX}/bin/lorikeet
