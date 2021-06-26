#!/bin/bash

mkdir -p $PREFIX/bin
chmod +x bin/*
cp bin/* $PREFIX/bin

mkdir -p $PREFIX/for_MacOS_users
chmod +x for_MacOS_users/*
cp for_MacOS_users/* $PREFIX/for_MacOS_users

if [[ "$OSTYPE" == "darwin"* ]]; then
  chmod +x for_MacOS_users/*
  cp for_MacOS_users/* $PREFIX/bin
fi

# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate";
do
  mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
  #cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
echo "#!/bin/sh" > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
echo "export PERL5LIB=$PREFIX/lib/perl5/site_perl/5.22.0/" >> "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
echo "#!/bin/sh" > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
echo "unset PERL5LIB" >> "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
