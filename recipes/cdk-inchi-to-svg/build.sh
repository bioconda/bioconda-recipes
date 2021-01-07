#!/bin/bash
cd cdk-inchi-to-svg 
mvn package 
mkdir -p $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
for i in $(find . -name "*with-dependencies*jar"); do install -m755 "$i" $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/cdk-inchi-to-svg.jar; done
#Create wrapper script
echo "#!/bin/bash" > ${PREFIX}/bin/cdk-inchi-to-svg
echo "java -jar $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/cdk-inchi-to-svg.jar \"\$@\"" >> ${PREFIX}/bin/cdk-inchi-to-svg
chmod +x ${PREFIX}/bin/cdk-inchi-to-svg