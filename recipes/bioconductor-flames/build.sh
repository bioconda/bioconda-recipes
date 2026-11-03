#!/bin/bash

# remove full `src/submodule` directory to avoid trying to vendor non-compiling version of minimap2
rm -r src/submodule

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
$R CMD INSTALL --build .

# include the activate and deactivate scripts to set the BASILISK_CUSTOM_PYTHON version
mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
install -m 755 "${RECIPE_DIR}/scripts/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
install -m 755 "${RECIPE_DIR}/scripts/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
install -m 755 "${RECIPE_DIR}/scripts/activate.fish" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.fish"
install -m 755 "${RECIPE_DIR}/scripts/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.fish"