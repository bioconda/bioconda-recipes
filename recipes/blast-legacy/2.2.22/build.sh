cp -R bin $PREFIX
cp -R data $PREFIX
cp -R doc $PREFIX
mkdir -p $PREFIX/etc/conda/activate.d/
echo "export BLASTMAT=$PREFIX/data/" > $PREFIX/etc/conda/activate.d/set_blastmat_env_variable.sh
mkdir -p $PREFIX/etc/conda/deactivate.d/
echo "unset BLASTMAT" > $PREFIX/etc/conda/deactivate.d/unset_blastmat_env_variable.sh
