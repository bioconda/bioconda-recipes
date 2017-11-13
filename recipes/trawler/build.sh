#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

rm -rf test_data examples
mkdir -p $outdir
cp -r * $outdir

# Short wrapper script
cat > $PREFIX/bin/trawler <<EOF
#!/bin/bash
export PERL5LIB=$outdir:$outdir/treg_comparator
$outdir/bin/trawler.pl \$@
unset PERL5LIB
EOF
chmod +x $PREFIX/bin/trawler
