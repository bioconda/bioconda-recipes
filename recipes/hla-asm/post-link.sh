HLA_ASM_DIR=$PREFIX/opt/hla-asm
DL_CMD="cd $HLA_ASM_DIR && wget 'https://www.dropbox.com/s/mnkig0fhaym43m0/reference_HLA_ASM.tar.gz' && tar -xvzf reference_HLA_ASM.tar.gz"
echo "HLA-ASM installed. It will not run without the reference file (800MB). Please download it manually, e.g." >> $PREFIX/.messages.txt
echo DL_CMD >> $PREFIX/.messages.txt
