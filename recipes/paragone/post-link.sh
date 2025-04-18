"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.add("ArgParse")' >> "${PREFIX}/.messages.txt" 2>&1
"${PREFIX}/bin/julia" -e 'using Pkg; Pkg.instantiate()' >> "${PREFIX}/.messages.txt" 2>&1

