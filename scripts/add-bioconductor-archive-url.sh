#!/bin/bash

# Add an archive URL as fallback to each bioconductor recipe for which it does not yet exist.

for recipe in recipes/bioconductor-**/meta.yaml
do
    grep bioc/src/contrib/Archive $recipe || sed -i -r "s@^( +)- 'https://bioconductor.org/packages/\{\{ bioc \}\}/bioc/src/contrib/\{\{ name \}\}_\{\{ version \}\}.tar.gz'@\1- 'https://bioconductor.org/packages/\{\{ bioc \}\}/bioc/src/contrib/\{\{ name \}\}_\{\{ version \}\}.tar.gz'\n\1- 'https://bioconductor.org/packages/\{\{ bioc \}\}/bioc/src/contrib/Archive/\{\{ name \}\}/\{\{ name \}\}_\{\{ version \}\}.tar.gz'@g" $recipe
done
