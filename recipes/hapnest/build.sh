#!/bin/bash

set -euxo pipefail

export JULIA_PKG_USE_CLI_GIT=true

# Turn off automatic precompilation
export JULIA_PKG_PRECOMPILE_AUTO=0


ln -s "${GCC}" "${BUILD_PREFIX}/gcc"


# Copy the required files to a shared directory
HAPNEST_SRC_DIR=${PREFIX}/share/hapnest
mkdir -p "${HAPNEST_SRC_DIR}"
mkdir -p "${PREFIX}/bin"
cp -r {commands,algorithms,evaluation,utils,optimisation,preprocessing,Project.toml,run_program.jl,config.yaml} "${HAPNEST_SRC_DIR}"


ln -s  ${HAPNEST_SRC_DIR}/run_program.jl  $PREFIX/bin
ln -s  ${HAPNEST_SRC_DIR}/commands/* $PREFIX/bin
ln -s  ${HAPNEST_SRC_DIR}/algorithms/genotype/genotype_algorithm.jl $PREFIX/bin
ln -s  ${HAPNEST_SRC_DIR}/algorithms/phenotype/phenotype_algorithm.jl $PREFIX/bin
ln -s  ${HAPNEST_SRC_DIR}/evaluation/evaluation.jl $PREFIX/bin
ln -s  ${HAPNEST_SRC_DIR}/integrations $PREFIX/bin
ln -s  ${HAPNEST_SRC_DIR}/utils/parameter_parsing.jl $PREFIX/bin
ln -s  ${HAPNEST_SRC_DIR}/optimisation/abc.jl $PREFIX/bin
ln -s  ${HAPNEST_SRC_DIR}/preprocessing/preprocessing.jl $PREFIX/bin


chmod +x ${HAPNEST_SRC_DIR}

#julia -e 'Pkg.init()'
julia -e 'import Pkg; Pkg.add("Conda")'
julia -e "using Pkg; Pkg.instantiate(); using Conda; Conda.add(\"bed-reader\"; channel=\"conda-forge\")"
julia -e 'import Pkg; Pkg.add("ArgParse")'
julia -e 'import Pkg; Pkg.add("YAML")'
julia -e 'import Pkg; Pkg.add("LsqFit")'
julia -e 'import Pkg; Pkg.add("DataFrames")'
julia -e 'import Pkg; Pkg.add("CSV")'
julia -e 'import Pkg; Pkg.add("CategoricalArrays")'
julia -e 'import Pkg; Pkg.add("DelimitedFiles")'
julia -e 'import Pkg; Pkg.add("Distances")'
julia -e 'import Pkg; Pkg.add("Distributions")'
julia -e 'import Pkg; Pkg.add("GpABC")'
julia -e 'import Pkg; Pkg.add("Impute")'
julia -e 'import Pkg; Pkg.add("MendelPlots")'
julia -e 'import Pkg; Pkg.add("Mmap")'
julia -e 'import Pkg; Pkg.add("Plots")'
julia -e 'import Pkg; Pkg.add("Printf")'
julia -e 'import Pkg; Pkg.add("ProgressMeter")'
julia -e 'import Pkg; Pkg.add("PyCall")'
julia -e 'import Pkg; Pkg.add("StatsBase")'
julia -e 'import Pkg; Pkg.add("StatsPlots")'
julia -e 'import Pkg; Pkg.add("YAML")'





