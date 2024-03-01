
#!/bin/bash
JAVA_VERSION=17.0.9_9
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
JAVA_DIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/java-for-gatk

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME
mkdir -p $JAVA_DIR

#
# We have downloaded Java from Adoptium as none of the OpenJDK-17 builds in Conda-forge are compatible with GATK. 
# To prevent conflicts with existing Java installations, we have adjusted the GATK wrapper script to utilize the downloaded 
# Java executable directly without needing to add it to the system path.
#
wget -c https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jre_x64_linux_hotspot_$JAVA_VERSION.tar.gz 
wget -O- -q -T 1 -t 1 https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jre_x64_linux_hotspot_$JAVA_VERSION.tar.gz.sha256.txt | sha256sum -c
tar -xzf OpenJDK17U-jre_x64_linux_hotspot_$JAVA_VERSION.tar.gz
mv jdk-17.0.9+9-jre/* $JAVA_DIR

#
# install custom gatk wrapper
#
cp $RECIPE_DIR/gatk ${PACKAGE_HOME}/gatk
chmod +x ${PACKAGE_HOME}/gatk
cp gatk-*-local.jar $PACKAGE_HOME

#
# install gatk's python packages 
#
unzip gatkPythonPackageArchive.zip -d gatkPythonPackageArchive
cd gatkPythonPackageArchive
$PYTHON -m pip install .

# Does not install the spark jars, this is done in the `build_spark.sh`
ln -s $PACKAGE_HOME/gatk $PREFIX/bin
ln -s $JAVA_DIR/bin/java $PREFIX/bin
