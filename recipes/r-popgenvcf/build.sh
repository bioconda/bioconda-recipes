#!/bin/bash
set -euo pipefail

# Standard bioconda R CMD INSTALL --build pattern.
"${R}" CMD INSTALL --build .

# The R package (this source tarball) intentionally does not ship a CLI
# entry point -- popgenVCF.R at the repo root is excluded from the built
# package via .Rbuildignore, since it is just a thin commandArgs()
# wrapper around popgenVCF::cli_main() meant for local/Docker use. Install
# an equivalent wrapper as a real executable so `popgenVCF ...` works the
# same way `plink`/`bcftools`/etc. do for a conda-installed user, without
# requiring them to know the package's internal entry-point function name.
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/popgenVCF" <<'WRAPPER'
#!/usr/bin/env Rscript
popgenVCF::cli_main(commandArgs(trailingOnly = TRUE))
WRAPPER
chmod +x "${PREFIX}/bin/popgenVCF"
