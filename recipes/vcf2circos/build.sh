#!/usr/bin/bash
set -eu

pip install . --no-deps
sed -i.bak '1 s|^.*$|#!/usr/bin/env python3|g' $PREFIX/bin/vcf2circos

# Check for latest compatible version of the config when updating the recipe on
# https://www.lbgi.fr/~lamouche/vcf2circos/
export latest="09012023"
wget https://www.lbgi.fr/~lamouche/vcf2circos/config_vcf2circos_${latest}.tar.gz
tar -xzf config_vcf2circos_${latest}.tar.gz
sed -i 's,\"Static\": \"/enadisk/maison/lamouche/dev_vcf2circos/Static\"\,,\"Static\": \"/Static\"\,,' $(pwd)/Static/options.json
rm config_vcf2circos_${latest}.tar.gz