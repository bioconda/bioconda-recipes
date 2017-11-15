#!/bin/bash

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $outdir
cp -r * $outdir

# Short wrapper script which sets PERL5LIB while running
cat > $PREFIX/bin/pfam_scan.pl <<EOF
#!/bin/bash
export PERL5LIB=$outdir:$outdir/
$outdir/pfam_scan.pl \$@
unset PERL5LIB
EOF
chmod +x $PREFIX/bin/pfam_scan.pl
