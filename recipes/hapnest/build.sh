#!/bin/bash

ln -s "${GCC}" "${BUILD_PREFIX}/gcc"

cp -r $SRC_DIR/run_program.jl  $PREFIX/bin
cp -r $SRC_DIR/commands/* $PREFIX/bin
cp -r $SRC_DIR/algorithms/genotype/genotype_algorithm.jl $PREFIX/bin
cp -r $SRC_DIR/algorithms/phenotype/phenotype_algorithm.jl $PREFIX/bin
cp -r $SRC_DIR/evaluation/evaluation.jl $PREFIX/bin
#cp -r $SRC_DIR/integrations $PREFIX
cp -r $SRC_DIR/utils/parameter_parsing.jl $PREFIX/bin
cp -r $SRC_DIR/optimisation/abc.jl $PREFIX/bin
cp -r $SRC_DIR/preprocessing/preprocessing.jl $PREFIX/bin

ln -s $PREFIX/bin/run_program.jl  $PREFIX/bin/hapnest

chmod +x $PREFIX/bin/hapnest

#julia -e 'Pkg.init()'
julia -e 'import Pkg; Pkg.add("ArgParse")'
julia -e 'import Pkg; Pkg.add("YAML")'
julia -e 'import Pkg; Pkg.add("LsqFit")'
julia -e 'import Pkg; Pkg.add("DataFrames")'
julia -e 'import Pkg; Pkg.add("Conda")'
julia -e 'using Conda; Conda.add("bed-reader")'
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





