"${PREFIX}/bin/julia" -e 'rm(ENV["JULIA_PKGDIR"], recursive=true)' >> "${PREFIX}/.messages.txt" 2>&1
