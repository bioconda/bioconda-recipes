#!/bin/bash

set -euxo pipefail

export JULIA_PKG_USE_CLI_GIT=true

# Turn off automatic precompilation
export JULIA_PKG_PRECOMPILE_AUTO=0

#https://github.com/JuliaLang/julia/issues/48873
export LD_LIBRARY_PATH=""

ln -s "${GCC}" "${BUILD_PREFIX}/gcc"

# define hapnest-specific dirs
DATA_DIR="$PWD/data/"
SCRIPT_DIR=${PREFIX}/share/hapnest

mkdir -p $DATA_DIR
mkdir -p $SCRIPT_DIR
mkdir -p ${PREFIX}/bin


export JULIA_DEPOT_PATH=$DATA_DIR/.julia
export JULIA_SSL_VERIFY=false

cp -r {commands,integrations,algorithms,evaluation,utils,optimisation,preprocessing,Project.toml,run_program.jl,config.yaml} $SCRIPT_DIR 

#ls -ltr $SCRIPT_DIR

cp  ${PREFIX}/share/hapnest/run_program.jl  $PREFIX/bin/

#for file in $SCRIPT_DIR/{commands/*,algorithms/genotype/*.jl,algorithms/phenotype/*,evaluation/evaluation.jl,evaluation/metrics/*.jl,integrations/gwas.jl,utils/{reference_data.jl,parameter_parsing.jl},optimisation/*,preprocessing/*,Project.toml,config.yaml}; do
#    ln -sf $file $PREFIX/bin/
#done


#ln -sf  ${PREFIX}/share/hapnest/commands/* $PREFIX/bin/
for file in ${PREFIX}/share/hapnest/commands/*; do
    ln -sf $file $PREFIX/bin/
done

#ln -sf  ${PREFIX}/share/hapnest/algorithms/genotype/* $PREFIX/bin/
for file in ${PREFIX}/share/hapnest/algorithms/genotype/*.jl; do
    ln -sf $file $PREFIX/bin/
done

#ln -sf  ${PREFIX}/share/hapnest/algorithms/phenotype/* $PREFIX/bin/
for file in ${PREFIX}/share/hapnest/algorithms/phenotype/*; do
    ln -sf $file $PREFIX/bin/
done

#ln -sf  ${PREFIX}/share/hapnest/evaluation/evaluation.jl  $PREFIX/bin/
for file in ${PREFIX}/share/hapnest/evaluation/metrics/*.jl; do
    ln -sf $file $PREFIX/bin/
done

ln -sf  ${PREFIX}/share/hapnest/integrations/gwas.jl  $PREFIX/bin/

ln -sf  ${PREFIX}/share/hapnest/utils/reference_data.jl $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/utils/parameter_parsing.jl  $PREFIX/bin/
#for file in ${PREFIX}/share/hapnest/utils/*; do
#    ln -sf $file $PREFIX/bin/
#done

#ln -sf  ${PREFIX}/share/hapnest/optimisation/* $PREFIX/bin/
for file in ${PREFIX}/share/hapnest/optimisation/*; do
    ln -sf $file $PREFIX/bin/
done

#ln -sf  ${PREFIX}/share/hapnest/preprocessing/* $PREFIX/bin/
for file in ${PREFIX}/share/hapnest/preprocessing/*; do
    ln -sf $file $PREFIX/bin/
done

ln -sf  ${PREFIX}/share/hapnest/Project.toml  $PREFIX/bin/
ln -sf  ${PREFIX}/share/hapnest/config.yaml  $PREFIX/bin/

#~/conda-bld/hapnest_1711833912133/test_tmp/run_program.jl": No such file or directory
chmod +x ${SCRIPT_DIR}
chmod +x ${PREFIX}/bin 

ls -ltr $PREFIX/bin
ls -ltr $SCRIPT_DIR

julia -e "using Pkg; Pkg.instantiate(); using Conda; Conda.add(\"bed-reader\"; channel=\"conda-forge\")"
 

julia -e "import Pkg; Pkg.add([\"Conda\", \"ArgParse\",\"YAML\", \"LsqFit\", \"DataFrames\", \"CSV\", \"CategoricalArrays\", \"DelimitedFiles\", \"Distances\", \"Distributions\", \"StatsPlots\", \"StatsBase\", \"PyCall\", \"Printf\", \"Plots\", \"Mmap\", \"MendelPlots\",  \"Impute\", \"GpABC\", \"ProgressMeter\"])"




