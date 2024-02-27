
#!/bin/bash
JAVA_VERSION=17.0.9_9
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
JAVA_DIR=$PREFIX/share/java-$JAVA_VERSION

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME
mkdir -p $JAVA_DIR

#
# download java - none of the openjdk-17 builds in conda-forge work with gatk, and GATK recommends adoptium's jdk builds so we are using their binaries below. 
#
#if [[ ${target_platform} =~ linux.* ]] ; then
wget -c https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jre_x64_linux_hotspot_$JAVA_VERSION.tar.gz 
wget -O- -q -T 1 -t 1 https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jre_x64_linux_hotspot_$JAVA_VERSION.tar.gz.sha256.txt | sha256sum -c
tar -xzf OpenJDK17U-jre_x64_linux_hotspot_$JAVA_VERSION.tar.gz
#else
#    echo "operating system not not supported"
#    exit 1
#fi

#
# install java
#
mv jdk-17.0.9+9-jre/* $JAVA_DIR
ls $JAVA_DIR/bin
ls $JAVA_DIR/lib

#
# install gatk
#
chmod +x gatk
cp gatk ${PACKAGE_HOME}/gatk
cp gatk-*-local.jar $PACKAGE_HOME

#
# install gatk's python packages 
#
unzip gatkPythonPackageArchive.zip -d gatkPythonPackageArchive
cd gatkPythonPackageArchive
python setup.py install

# Does not install the spark jars, this is done in the `build_spark.sh`
ln -s $PACKAGE_HOME/gatk $PREFIX/bin
ln -s $JAVA_DIR/bin/java $PREFIX/bin
