HLA_ASM_DIR=$PREFIX/opt/hla-asm
REF_DIR=$HLA_ASM_DIR/reference_HLA_ASM 
DL_CMD="cd $HLA_ASM_DIR && wget 'https://www.dropbox.com/s/mnkig0fhaym43m0/reference_HLA_ASM.tar.gz' && tar -xvzf reference_HLA_ASM.tar.gz"
MESSAGE=""
if [ ! -d $REF_DIR ]; then
	echo $DL_CMD
	{ eval $DL_CMD && MESSAGE="downloaded reference (~800MB)"; } || { MESSAGE="could not download reference. Please download it manually, like: $DL_CMD"; }
else
	MESSAGE="reference folder $REF_DIR found. not downloading reference"
fi
echo $MESSAGE >> $PREFIX/.messages.txt 
