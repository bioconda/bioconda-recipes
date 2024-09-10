#!/bin/bash

perl Makefile.PL
make
make install

mkdir -pv $PREFIX/bin 
mkdir -pv $PREFIX/lib/perl5
mkdir -pv $PREFIX/db/{fasta,blast}
find $PREFIX -type d -exec chmod -v 775 {} \;

files=$(\ls -1 SneakerNet.plugins/*.pl SneakerNet.plugins/*.py SneakerNet.plugins/*.sh scripts/*.pl)
ls -lh $files
chmod -v +x $files

for i in $files; do
  cp -nv $i $PREFIX/bin/$(basename $i)
done
mkdir -pv $PREFIX/lib/perl5
cp -v lib/perl5/SneakerNet.pm $PREFIX/lib/perl5

# SneakerNet depends on plugins in the SneakerNet.plugins
# subdirectory. Hack this path by just providing a symlink
ln -sv $PREFIX/bin $PREFIX/SneakerNet.plugins

# Need to keep the conf.bak and copy it to 
# the working copy conf.
cp -r config.bak $PREFIX/config.bak
cp -r config.bak $PREFIX/config
cat $PREFIX/config.bak/settings.conf | \
  sed '/KRAKEN_DEFAULT_DB/d' > $PREFIX/config/settings.conf

KALAMARI_VER=$(downloadKalamari.pl --version)
KRAKEN_DEFAULT_DB="$PREFIX/share/kalamari-$KALAMARI_VER/kalamari-kraken1"
echo "KRAKEN_DEFAULT_DB  $KRAKEN_DEFAULT_DB" >> $PREFIX/config/settings.conf

export PERL5LIB=$PERL5LIB:$PREFIX/lib/perl5


