mkdir -p ${PREFIX}/bin
# Check if linux or osx
if [ -z ${OSX_ARCH+x} ]; then
  mv vcf_validator_linux ${PREFIX}/bin/vcf_validator
  mv vcf_assembly_checker_linux ${PREFIX}/bin/vcf_assembly_checker
else
  mv vcf_validator_macos ${PREFIX}/bin/vcf_validator
  mv vcf_assembly_checker_macos ${PREFIX}/bin/vcf_assembly_checker
fi

chmod 755 ${PREFIX}/bin/vcf_assembly_checker ${PREFIX}/bin/vcf_validator
