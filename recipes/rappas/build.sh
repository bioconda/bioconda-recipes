#! /bin/bash

#create directory following bioconda rules
rappas_dir="${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $rappas_dir

#compile
cd $SRC_DIR
pwd
ant -f build-cli.xml

#copy both the jar and the stub version to /opt
#the jar allows tuning of JVM options,
#ex: when requiring large RAM amount of RAM
#the stub concatenate 'rappas' is for normal usage
cp dist/RAPPAS.jar $rappas_dir
cat stub.sh dist/RAPPAS.jar > rappas && chmod +x rappas
cp rappas $rappas_dir

#link in /bin, following bioconda rules
mkdir -p ${PREFIX}/bin
ln -s ${rappas_dir}/rappas ${PREFIX}/bin/rappas
ln -s ${rappas_dir}/RAPPAS.jar ${PREFIX}/bin/RAPPAS.jar

