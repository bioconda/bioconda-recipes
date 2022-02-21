mkdir -p $PREFIX/bin
cp *.sh $PREFIX/bin

# Create a config if not already present

if [ ! -e $PREFIX/bin/atlas-fastq-provider-config.sh ]; then
    cp atlas-fastq-provider-config.sh.default $PREFIX/bin/atlas-fastq-provider-config.sh
fi
