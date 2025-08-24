#!/usr/bin/env bash

# script for compiling:
compile_file="${SRC_DIR}/src/compile.jl"
# file with precompilation statements: 
precompiled_file="${SRC_DIR}/src/precompiled.jl"
# test files for precompilation run, if necessary:
#contigs="${RECIPE_DIR}/precompile_statements/07673_lcal.fa"
#reference="${RECIPE_DIR}/precompile_statements/07673_Alitta_succinea.fa"
# directory to contain the finished build:
build_dir="${SRC_DIR}/build"
# inside build_dir, contains directories artifacts, bin with executable patchwork, and lib:
patchwork_dir="patchwork-${PKG_VERSION}"

# not sure if this is necessary, but can't have these in the Patchwork module:
julia -e "import Pkg; Pkg.add([\"PackageCompiler\"])"
# precompile: (GETTING A MEMORY ERROR HERE, SO I'M OMITTING THIS STEP NOW)
#julia -e "import Pkg; Pkg.add([\"ArgParse\", \"BioAlignments\", \"BioCore\", \"BioSequences\", \"BioSymbols\", \"CSV\", 
#          \"DataFrames\", \"FASTX\", \"GFF3\", \"GenomicFeatures\", \"Random\", \"Statistics\"])"
#julia --trace-compile="${precompiled_file}" "${SRC_DIR}/src/Patchwork.jl" --contigs "${contigs}" --reference "${reference}"

# this is not entirely elegant, but you need the .toml files for compilation and conda-build only 
# copies the stuff inside the "src"-directory of the repo to its own working directory SRC_DIR,
# so make sure you have the .toml files in the RECIPE_DIR together with meta.yaml and build.sh
cp "${RECIPE_DIR}/dependencies/Project.toml" "${SRC_DIR}"
cp "${RECIPE_DIR}/dependencies/Manifest.toml" "${SRC_DIR}"

mkdir -p "${build_dir}/${patchwork_dir}"
# PackageCompiler.jl get_compiler() searches for "gcc" and "clang", therefore:
if [ -f "${GCC}" ]
then
    ln -s "${GCC}" "${BUILD_PREFIX}/bin/gcc"
elif [ -f "${CLANG}" ]
then
    ln -s "${CLANG}" "${BUILD_PREFIX}/bin/clang"
fi

# compile Patchwork: 
julia "${compile_file}" "${SRC_DIR}" "${precompiled_file}" "${build_dir}/${patchwork_dir}"

# bundle together for conda packaging: 
mkdir -p "${PREFIX}/bin"
cp -r "${build_dir}"/* "${PREFIX}/bin"
ln -s "${PREFIX}/bin/${patchwork_dir}/bin/patchwork" "${PREFIX}/bin/patchwork"