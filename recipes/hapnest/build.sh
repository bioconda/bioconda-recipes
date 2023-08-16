#!/bin/bash

cp run_program.jl $PREFIX/bin/hapnest

julia -e 'Pkg.init()'
julia -e 'Pkg.instantiate()'
julia -e 'Pkg.add("ArgParse")'
julia -e 'Pkg.add("CSV")'
julia -e 'Pkg.add("CategoricalArrays")'
julia -e 'Pkg.add("Conda")'
julia -e 'Pkg.add("DataFrames")'
julia -e 'Pkg.add("DelimitedFiles")'
julia -e 'Pkg.add("Distances")'
julia -e 'Pkg.add("Distributions")'
julia -e 'Pkg.add("GpABC")'
julia -e 'Pkg.add("Impute")'
julia -e 'Pkg.add("LsqFit")'
julia -e 'Pkg.add("MendelPlots")'
julia -e 'Pkg.add("Mmap")'
julia -e 'Pkg.add("Plots")'
julia -e 'Pkg.add("Printf")'
julia -e 'Pkg.add("ProgressMeter")'
julia -e 'Pkg.add("PyCall")'
julia -e 'Pkg.add("StatsBase")'
julia -e 'Pkg.add("StatsPlots")'
julia -e 'Pkg.add("YAML")'
julia -e 'using Conda'
julia -e 'Conda.add("bed-reader")' 

