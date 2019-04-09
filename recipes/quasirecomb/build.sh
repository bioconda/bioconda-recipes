cp QuasiRecomb.jar $PREFIX
mkdir -p $PREFIX/etc/conda/activate.d
echo 'export JAR_PATH=$CONDA_PREFIX' >> $PREFIX/etc/conda/activate.d/env_vars.sh
