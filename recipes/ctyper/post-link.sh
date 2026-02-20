#!/bin/bash


echo "ctyper has been installed successfully! "
echo ""
echo "Background kmers, public nameclature files are included at $PREFIX/share/ctyper/data/backgrounds.list, and post-analysis tools are included at $PREFIX/share/ctyper/tools/ "
echo ""
echo "Remember to download the external matrix database files located at https://zenodo.org/records/14399353i "
echo ""
echo -e "example running: \nctyper -i CramFile -m HprcCpcHgsvc_final42_matrix.v1.0.txt -b $PREFIX/share/ctyper/data/backgrounds.list -c 1 -o ctyper.out \npython $PREFIX/share/ctyper/tools/Annotation/SampleAnnotate.py -i ctyper.out -a PangenomeAlleles_annotationfix.v1.0.tsv -o genotype.txt "
echo ""
echo "For more running information, please visit https://github.com/ChaissonLab/Ctyper "
