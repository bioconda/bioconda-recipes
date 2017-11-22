#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

rm -rf test_data examples
mkdir -p $outdir
cp -r * $outdir

# Short wrapper script
cat > $PREFIX/bin/trawler <<EOF
#!/bin/bash
# Last line of script to ensure any failure return code is passed on:
PERL5LIB=$outdir:$outdir/treg_comparator $outdir/bin/trawler.pl \$@
EOF
chmod +x $PREFIX/bin/trawler
