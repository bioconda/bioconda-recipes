#!/bin/bash

set -euxo pipefail

export JULIA_PKG_USE_CLI_GIT=true

# Turn off automatic precompilation
export JULIA_PKG_PRECOMPILE_AUTO=0


ln -s "${GCC}" "${BUILD_PREFIX}/gcc"


# Copy the required files to a shared directory
SCRIPT_DIR=${PREFIX}/share/hapnest
mkdir -p "${SCRIPT_DIR}"
mkdir -p "${PREFIX}/bin"
cp -r {commands,integrations,algorithms,evaluation,utils,optimisation,preprocessing,Project.toml,run_program.jl,config.yaml} "${SCRIPT_DIR}"


ln -s  ${SCRIPT_DIR}/run_program.jl  $PREFIX/bin/
ln -s  ${SCRIPT_DIR}/commands/* $PREFIX/bin/
ln -s  ${SCRIPT_DIR}/algorithms/genotype/* $PREFIX/bin/
ln -s  ${SCRIPT_DIR}/algorithms/phenotype/* $PREFIX/bin/
ln -s  ${SCRIPT_DIR}/evaluation/* $PREFIX/bin/
ln -s  ${SCRIPT_DIR}/integrations/gwas.jl  $PREFIX/bin/
ln -s  ${SCRIPT_DIR}/utils/* $PREFIX/bin/
ln -s  ${SCRIPT_DIR}/optimisation/* $PREFIX/bin/
ln -s  ${SCRIPT_DIR}/preprocessing/* $PREFIX/bin/
ln -s  ${SCRIPT_DIR}/Project.toml  $PREFIX/bin/
ln -s  ${SCRIPT_DIR}/config.yaml  $PREFIX/bin/

chmod +x ${SCRIPT_DIR}

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





