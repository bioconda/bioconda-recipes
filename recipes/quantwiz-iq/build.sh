mkdir -p $PREFIX/bin
module_dir=$PREFIX/MODULES
mkdir -p $module_dir

cp QuantWiz_IQ.pl $PREFIX/bin
cp MODULES/*.pm $PREFIX/MODULES/

mkdir -p $PREFIX/tmp_dir
cp -r Purity_correction $PREFIX/tmp_dir

# Short wrapper script
cat > $PREFIX/bin/QuantWiz_IQ <<EOF
#!/bin/bash
PERL5LIB=$module_dir QuantWiz_IQ.pl "\$@"
EOF
chmod +x $PREFIX/bin/QuantWiz_IQ

cat > $PREFIX/tmp_dir/test_param.txt <<EOF
Spectra_Folder=$PREFIX/tmp_dir/Input
Input_file_extension=mgf
Label_type=iTRAQ
Plex=8plex
min_reporters=1
Spectrum_area=S
Base_reporter=113
Normalization=no
Peak_intensity_threshold=0
Tol_unit=Da
Tol_min=0.05
Tol_max=0.05
Purity_corrections_values=$PREFIX/tmp_dir/Purity_correction/iTRAQ8plex.tsv
EOF

sed -i.bak "s|/usr/bin/perl|/usr/bin/env perl|g" $PREFIX/bin/QuantWiz_IQ.pl
rm $PREFIX/bin/*.bak
