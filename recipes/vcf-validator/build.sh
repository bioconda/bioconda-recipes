

mkdir -p ${PREFIX}/bin
# Check if linux or osx
if [ -z ${OSX_ARCH+x} ]; then
  curl -LJo ${PREFIX}/bin/vcf_validator  https://github.com/EBIvariation/vcf-validator/releases/download/v${PKG_VERSION}/vcf_validator_linux \
    && curl -LJo ${PREFIX}/bin/vcf_assembly_checker  https://github.com/EBIvariation/vcf-validator/releases/download/v${PKG_VERSION}/vcf_assembly_checker_linux \
    && chmod 755 ${PREFIX}/bin/vcf_assembly_checker ${PREFIX}/bin/vcf_validator
else
  curl -LJo ${PREFIX}/bin/vcf_validator  https://github.com/EBIvariation/vcf-validator/releases/download/v${PKG_VERSION}/vcf_validator_macos \
    && curl -LJo ${PREFIX}/bin/vcf_assembly_checker  https://github.com/EBIvariation/vcf-validator/releases/download/v${PKG_VERSION}/vcf_assembly_checker_macos \
    && chmod 755 ${PREFIX}/bin/vcf_assembly_checker ${PREFIX}/bin/vcf_validator
fi
