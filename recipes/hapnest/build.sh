#!/bin/bash

set -euxo pipefail

export JULIA_PKG_USE_CLI_GIT=true

# Turn off automatic precompilation
export JULIA_PKG_PRECOMPILE_AUTO=0


ln -s "${GCC}" "${BUILD_PREFIX}/gcc"


# Copy the required files to a shared directory
#SCRIPT_DIR=${PREFIX}/share/hapnest
mkdir -p ${PREFIX}/share/hapnest
mkdir -p ${PREFIX}/bin
cp -r {commands,integrations,algorithms,evaluation,utils,optimisation,preprocessing,Project.toml,run_program.jl,config.yaml} ${PREFIX}/share/hapnest


ln -sf  ${PREFIX}/share/hapnest/run_program.jl  $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/commands/* $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/algorithms/genotype/* $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/algorithms/phenotype/* $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/evaluation/* $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/integrations/gwas.jl  $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/utils/* $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/optimisation/* $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/preprocessing/* $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/Project.toml  $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/config.yaml  $PREFIX/bin/

chmod +x ${PREFIX}/share/hapnest

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





