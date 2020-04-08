### Reconfiguring/fixing VirSorter Makefile
cd Scripts/
sed 's/gcc/\$\(CC\)/g' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
sed 's/\\\.o/*\\\.o/' Makefile > Makefile.tmp && mv Makefile.tmp Makefile


### Compiling programs
make clean
make


### Cleaning up
rm Makefile Sliding_windows_3.*


### Organizing executables
cd ../
mkdir -pv "${PREFIX}"/bin/
mv wrapper_phage_contigs_sorter_iPlant.pl Scripts/ "${PREFIX}"/bin/


### Creating scripts to set env variables during activation/deactivation of env
mkdir -p "${PREFIX}"/etc/conda/activate.d "${PREFIX}"/etc/conda/deactivate.d
# Setting perl path when activating
echo '#!/bin/sh' > "${PREFIX}"/etc/conda/activate.d/env_vars.sh
echo 'export CONDA_PERL5LIB=$(find "${CONDA_PREFIX}" -type d -path "*/site_perl/*" -prune | paste -s -d":")' >> "${PREFIX}"/etc/conda/activate.d/env_vars.sh
echo 'export PERL5LIB="${CONDA_PERL5LIB}":"${PERL5LIB}"' >> "${PREFIX}"/etc/conda/activate.d/env_vars.sh
# Resetting perl path when deactivating
echo '#!/bin/sh' > "${PREFIX}"/etc/conda/deactivate.d/env_vars.sh
echo 'export PERL5LIB=${PERL5LIB//"${CONDA_PERL5LIB}":/}' >> "${PREFIX}"/etc/conda/deactivate.d/env_vars.sh
