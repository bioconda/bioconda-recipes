mkdir -p ${PREFIX}/bin
# Check if linux or osx

 # Rename to a remove suffix
 mv vcf_validator* ${PREFIX}/bin/vcf_validator
 mv vcf_assembly_checker* ${PREFIX}/bin/vcf_assembly_checker

 echo "PATH: " $PATH
 echo "LIB PATH: " $LIBRARY_PATH
 echo "DYLD PATH: " $DYLD_LIBRARY_PATH
 echo "SYSROOT: " $SYSROOT
 brew info boost || true
 brew info zstd || true
 brew info xz || true
 bew info icu4c || true
 conda info icu4c || true
 conda info icu || true
chmod 755 ${PREFIX}/bin/vcf_assembly_checker ${PREFIX}/bin/vcf_validator
