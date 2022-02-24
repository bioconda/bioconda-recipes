mkdir -p $PREFIX/bin
module_dir=$PREFIX/MODULES
mkdir -p $module_dir

cp QuantWiz_IQ.pl $PREFIX/bin
cp MODULES/*.pm $PREFIX/MODULES/

cp -r Purity_correction $PREFIX/bin

# Short wrapper script
cat > $PREFIX/bin/QuantWiz_IQ <<EOF
#!/bin/bash
PERL5LIB=$module_dir exec perl $PREFIX/bin/QuantWiz_IQ.pl "\$@"
EOF
chmod +x $PREFIX/bin/QuantWiz_IQ

sed -i.bak 's|#!/usr/bin/perl|#!/usr/bin/env perl|' QuantWiz_IQ.pl

