#!/bin/bash
mkdir -p $PREFIX/lib/czlab_perl_lib
cp -r ./* $PREFIX/lib/czlab_perl_lib

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"

echo "P_BIOPERL=\$(dirname \$(dirname \$(find $PREFIX/lib -name SeqIO.pm)))" > "${PREFIX}/etc/conda/activate.d/env_vars_czlab_perl_lib.sh"
echo "export PERL5LIB=$PREFIX/lib/czlab_perl_lib:\$P_BIOPERL" >> "${PREFIX}/etc/conda/activate.d/env_vars_czlab_perl_lib.sh"

echo "unset PERL5LIB" > "${PREFIX}/etc/conda/deactivate.d/env_vars_czlab_perl_lib.sh"


chmod u+x "${PREFIX}/etc/conda/activate.d/env_vars_czlab_perl_lib.sh"
chmod u+x "${PREFIX}/etc/conda/deactivate.d/env_vars_czlab_perl_lib.sh"
