#!/bin/bash
set -e

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -ldl"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|"gcc-11"|"$CC"|' siprosV4CmakeAll/make
sed -i.bak 's|"g++-11"|"$CXX"|' siprosV4CmakeAll/make
rm -rf siprosV4CmakeAll/*.bak

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cd siprosV4CmakeAll

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
    -Wno-dev -Wno-deprecated --no-warn-unused-cli \
    "${CONFIG_ARGS}"
ninja -C build -j "${CPU_COUNT}"

cd ..

cp -rf EnsembleScripts "${PREFIX}"
cp -rf V4Scripts "${PREFIX}"
cp -rf configTemplates "${PREFIX}"

for script in sipros_prepare_protein_database.py sipros_psm_tabulating.py sipros_ensemble_filtering.py sipros_peptides_assembling.py; do
    baseName=$(basename $script .py)
    sed -i.bak '1i#!/usr/bin/env python\n' "$PREFIX/EnsembleScripts/$script"
    ln -sf "$PREFIX/EnsembleScripts/$script" "$PREFIX/bin/EnsembleScripts_$baseName"
    rm -rf $PREFIX/EnsembleScripts/*.bak
done

for script in sipros_peptides_filtering.py sipros_peptides_assembling.py ClusterSip.py; do
    baseName=$(basename $script .py)
    sed -i.bak '1i#!/usr/bin/env python\n' "$PREFIX/V4Scripts/$script"
    ln -sf "$PREFIX/V4Scripts/$script" "$PREFIX/bin/V4Scripts_$baseName"
    rm -rf $PREFIX/V4Scripts/*.bak
done

for script in refineProteinFDR.R getSpectraCountInEachFT.R makeDBforLabelSearch.R getLabelPCTinEachFT.R; do
    baseName=$(basename $script .R)
    sed -i.bak '1i#!/usr/bin/env Rscript\n' "$PREFIX/V4Scripts/$script"
    ln -sf "$PREFIX/V4Scripts/$script" "$PREFIX/bin/V4Scripts_$baseName"
    rm -rf $PREFIX/V4Scripts/*.bak
done

install -v -m 755 "$RECIPE_DIR/Raxport.sh" "$PREFIX/bin"
install -v -m 755 "$RECIPE_DIR/copyConfigTemplate.sh" "$PREFIX/bin"
