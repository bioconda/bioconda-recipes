#! /bin/bash

echo "PREFIX: ${PREFIX}"
echo "SRC_DIR: ${SRC_DIR}"
pwd
#create directory following bioconda recipe
rappas_dir="${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $rappas_dir
#compile
cd $SRC_DIR
pwd
ant -f build-cli.xml
cp dist/RAPPAS.jar $rappas_dir
cat stub.sh dist/RAPPAS.jar > rappas && chmod +x rappas
cp rappas $rappas_dir
#link in /bin
mkdir -p ${PREFIX}/bin
ln -s ${rappas_dir}/rappas ${PREFIX}/bin/rappas
ln -s ${rappas_dir}/RAPPAS.jar ${PREFIX}/bin/RAPPAS.jar

