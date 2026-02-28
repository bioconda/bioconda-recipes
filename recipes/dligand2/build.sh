mkdir -p ${PREFIX}/bin ${PREFIX}/data
cp bin/dligand2.gnu ${PREFIX}/bin/dligand2
cp bin/*2 ${PREFIX}/data

#export DATADIR env var
mkdir -p ${PREFIX}/etc/conda/{activate,deactivate}.d
touch ${PREFIX}/etc/conda/{activate,deactivate}.d/env_vars.sh
echo "export DATADIR=${PREFIX}/data" >> ${PREFIX}/etc/conda/activate.d/env_vars.sh
echo "export DATADIR=" >> ${PREFIX}/etc/conda/deactivate.d/env_vars.sh
