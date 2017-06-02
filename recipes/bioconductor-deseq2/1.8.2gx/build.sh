#!/bin/sh
wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/BiocGenerics_0.14.0.tar.gz
sha256sum BiocGenerics_0.14.0.tar.gz | awk '{ if ($1 == "5e55e0f5c6577935d169f62268dc05a168a2f607b652d44a919cb16caca7952e") exit 0; else exit 1}'
tar xfz BiocGenerics_0.14.0.tar.gz
cd BiocGenerics
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm BiocGenerics -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/S4Vectors_0.6.5.tar.gz
sha256sum S4Vectors_0.6.5.tar.gz | awk '{ if ($1 == "25f82ea9278cfc93b8dadb70fe3b6d114719ea4247c28178d699fde8cacd68f0") exit 0; else exit 1}'
tar xfz S4Vectors_0.6.5.tar.gz
cd S4Vectors
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm S4Vectors -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/IRanges_2.2.7.tar.gz
sha256sum IRanges_2.2.7.tar.gz | awk '{ if ($1 == "0609e1887e17ab75f8fcabb40e7c5995a4033c2c6e764e73bda8d35350561861") exit 0; else exit 1}'
tar xfz IRanges_2.2.7.tar.gz
cd IRanges
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm IRanges -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/GenomeInfoDb_1.4.2.tar.gz
sha256sum GenomeInfoDb_1.4.2.tar.gz | awk '{ if ($1 == "3d4ff22c6a11192ee1e313042ff0da4703b18c72f2247be73a0590769328d05a") exit 0; else exit 1}'
tar xfz GenomeInfoDb_1.4.2.tar.gz
cd GenomeInfoDb
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm GenomeInfoDb -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/XVector_0.8.0.tar.gz
sha256sum XVector_0.8.0.tar.gz | awk '{ if ($1 == "0da74db92148cd3ac9ce1b77d763599bc924700b0df423be1af1eb8fa778009b") exit 0; else exit 1}'
tar xfz XVector_0.8.0.tar.gz
cd XVector
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm XVector -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/GenomicRanges_1.20.6.tar.gz
sha256sum GenomicRanges_1.20.6.tar.gz | awk '{ if ($1 == "9d2bedd17a73864406d0284ddea2d28aef84c7c969b6924d8be2285d96f14e13") exit 0; else exit 1}'
tar xfz GenomicRanges_1.20.6.tar.gz
cd GenomicRanges
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm GenomicRanges -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/Rcpp_0.12.0.tar.gz
sha256sum Rcpp_0.12.0.tar.gz | awk '{ if ($1 == "68782050f5252c4246f1b5b335105eccf4c804d57a0cd41eb63a300f7e0241a0") exit 0; else exit 1}'
tar xfz Rcpp_0.12.0.tar.gz
cd Rcpp
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm Rcpp -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/RcppArmadillo_0.5.500.2.0.tar.gz
sha256sum RcppArmadillo_0.5.500.2.0.tar.gz | awk '{ if ($1 == "f30155fdd4745b4c9a548a25a30b6ae5fe3e3f6cf4136ac485a75c90555934a0") exit 0; else exit 1}'
tar xfz RcppArmadillo_0.5.500.2.0.tar.gz
cd RcppArmadillo
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm RcppArmadillo -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/Biobase_2.28.0.tar.gz
sha256sum Biobase_2.28.0.tar.gz | awk '{ if ($1 == "056b12f15e4164c3ea22bb3462ae2e5d7f391b91e473c014ee51e5460431ffa6") exit 0; else exit 1}'
tar xfz Biobase_2.28.0.tar.gz
cd Biobase
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm Biobase -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/lambda.r_1.1.7.tar.gz
sha256sum lambda.r_1.1.7.tar.gz | awk '{ if ($1 == "8ae36527124752f7af01eb84a55fa77716226b0e76dd03966b83d9583dcfbfd3") exit 0; else exit 1}'
tar xfz lambda.r_1.1.7.tar.gz
cd lambda.r
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm lambda.r -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/futile.options_1.0.0.tar.gz
sha256sum futile.options_1.0.0.tar.gz | awk '{ if ($1 == "ee84ece359397fbb63f145d11af678f5c8618570971e78cc64ac60dc0d14e8c2") exit 0; else exit 1}'
tar xfz futile.options_1.0.0.tar.gz
cd futile.options
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm futile.options -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/futile.logger_1.4.1.tar.gz
sha256sum futile.logger_1.4.1.tar.gz | awk '{ if ($1 == "a1e485e943d288b92a2af3337b333be95d1b51246dd14be9f18ae5ce626894de") exit 0; else exit 1}'
tar xfz futile.logger_1.4.1.tar.gz
cd futile.logger
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm futile.logger -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/snow_0.3-13.tar.gz
sha256sum snow_0.3-13.tar.gz | awk '{ if ($1 == "ceb6af66f8c988a7606c4ba2d7ccf84c14bca6c376f8d9133089296607c14bc1") exit 0; else exit 1}'
tar xfz snow_0.3-13.tar.gz
cd snow
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm snow -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/BiocParallel_1.2.20.tar.gz
sha256sum BiocParallel_1.2.20.tar.gz | awk '{ if ($1 == "b537ff2f7a46982b5897805c40cba63846acfdf855530c3c0c36d57276fb456a") exit 0; else exit 1}'
tar xfz BiocParallel_1.2.20.tar.gz
cd BiocParallel
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm BiocParallel -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/DBI_0.3.1.tar.gz
sha256sum DBI_0.3.1.tar.gz | awk '{ if ($1 == "1c26535720f146fae8cc9ef6e190619967abf296706a5b5a1e8242cbbb5a4576") exit 0; else exit 1}'
tar xfz DBI_0.3.1.tar.gz
cd DBI
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm DBI -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/RSQLite_1.0.0.tar.gz
sha256sum RSQLite_1.0.0.tar.gz | awk '{ if ($1 == "8e0cfca19afbc61f40c6d86018cd723a7e00f16d0944c4637f07a18fb6d76121") exit 0; else exit 1}'
tar xfz RSQLite_1.0.0.tar.gz
cd RSQLite
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm RSQLite -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/AnnotationDbi_1.30.1.tar.gz
sha256sum AnnotationDbi_1.30.1.tar.gz | awk '{ if ($1 == "cefd8d389e71e9b0002cdca78b8d4ae39a950248aaefcf647faaeaa13a2643bb") exit 0; else exit 1}'
tar xfz AnnotationDbi_1.30.1.tar.gz
cd AnnotationDbi
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm AnnotationDbi -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/XML_3.98-1.3.tar.gz
sha256sum XML_3.98-1.3.tar.gz | awk '{ if ($1 == "5e1fb547848b12b9b1a14a1e647891d62dbbebb2a87da28e10e095a1d0f52a49") exit 0; else exit 1}'
tar xfz XML_3.98-1.3.tar.gz
cd XML
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm XML -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/xtable_1.7-4.tar.gz
sha256sum xtable_1.7-4.tar.gz | awk '{ if ($1 == "47629a31185591be30b13ae3a656fc24360760996975e292f4fa7954c0257dbb") exit 0; else exit 1}'
tar xfz xtable_1.7-4.tar.gz
cd xtable
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm xtable -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/annotate_1.46.1.tar.gz
sha256sum annotate_1.46.1.tar.gz | awk '{ if ($1 == "a687835e735c74ce1a19127758626986c6bd495cda5be7b17dfd4318ac5640f7") exit 0; else exit 1}'
tar xfz annotate_1.46.1.tar.gz
cd annotate
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm annotate -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/survival_2.38-3.tar.gz
sha256sum survival_2.38-3.tar.gz | awk '{ if ($1 == "2588ba869471d97a42628611496ba0ce6ade188143f673af41987c7d4a8972c2") exit 0; else exit 1}'
tar xfz survival_2.38-3.tar.gz
cd survival
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm survival -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/genefilter_1.50.0.tar.gz
sha256sum genefilter_1.50.0.tar.gz | awk '{ if ($1 == "3808a8d5d9853c7915c5ba74e992d96470c4d546d7d6cbea03c4e43e5b68df77") exit 0; else exit 1}'
tar xfz genefilter_1.50.0.tar.gz
cd genefilter
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm genefilter -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/lattice_0.20-33.tar.gz
sha256sum lattice_0.20-33.tar.gz | awk '{ if ($1 == "8f46260a14364d945c7b74587cdb54986f36303588dd14010a33d15dba085931") exit 0; else exit 1}'
tar xfz lattice_0.20-33.tar.gz
cd lattice
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm lattice -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/locfit_1.5-9.1.tar.gz
sha256sum locfit_1.5-9.1.tar.gz | awk '{ if ($1 == "f524148fdb29aac3a178618f88718d3d4ac91283014091aa11a01f1c70cd4e51") exit 0; else exit 1}'
tar xfz locfit_1.5-9.1.tar.gz
cd locfit
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm locfit -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/RColorBrewer_1.1-2.tar.gz
sha256sum RColorBrewer_1.1-2.tar.gz | awk '{ if ($1 == "f3e9781e84e114b7a88eb099825936cc5ae7276bbba5af94d35adb1b3ea2ccdd") exit 0; else exit 1}'
tar xfz RColorBrewer_1.1-2.tar.gz
cd RColorBrewer
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm RColorBrewer -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/geneplotter_1.46.0.tar.gz
sha256sum geneplotter_1.46.0.tar.gz | awk '{ if ($1 == "ba930931a39ffbe5aa243b0886844921afdf7028ab904fd50aa4edcb63e1d257") exit 0; else exit 1}'
tar xfz geneplotter_1.46.0.tar.gz
cd geneplotter
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm geneplotter -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/plyr_1.8.3.tar.gz
sha256sum plyr_1.8.3.tar.gz | awk '{ if ($1 == "f31afae9b1998dcf806d9ec82474fac49837082e310a2c6e3ee3cbcb55ff641b") exit 0; else exit 1}'
tar xfz plyr_1.8.3.tar.gz
cd plyr
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm plyr -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/digest_0.6.8.tar.gz
sha256sum digest_0.6.8.tar.gz | awk '{ if ($1 == "3062422c2ca917e52749464d63084a0d3cc061f59083f069280ec26336ce2f55") exit 0; else exit 1}'
tar xfz digest_0.6.8.tar.gz
cd digest
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm digest -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/gtable_0.1.2.tar.gz
sha256sum gtable_0.1.2.tar.gz | awk '{ if ($1 == "b08ba8e62e0ce05e7a4c07ba3ffa67719161db62438b04f14343f8928d74304d") exit 0; else exit 1}'
tar xfz gtable_0.1.2.tar.gz
cd gtable
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm gtable -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/stringi_0.5-5.tar.gz
sha256sum stringi_0.5-5.tar.gz | awk '{ if ($1 == "1cd67b64f287aac9e8fd95dd4a0cab829e0fb7870fd264ede281be0b65ce7ca0") exit 0; else exit 1}'
tar xfz stringi_0.5-5.tar.gz
cd stringi
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm stringi -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/magrittr_1.5.tar.gz
sha256sum magrittr_1.5.tar.gz | awk '{ if ($1 == "05c45943ada9443134caa0ab24db4a962b629f00b755ccf039a2a2a7b2c92ae8") exit 0; else exit 1}'
tar xfz magrittr_1.5.tar.gz
cd magrittr
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm magrittr -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/stringr_1.0.0.tar.gz
sha256sum stringr_1.0.0.tar.gz | awk '{ if ($1 == "f8267db85b83c0fc8904009719c93296934775b0d6890c996ec779ec5336df4a") exit 0; else exit 1}'
tar xfz stringr_1.0.0.tar.gz
cd stringr
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm stringr -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/reshape2_1.4.1.tar.gz
sha256sum reshape2_1.4.1.tar.gz | awk '{ if ($1 == "fbd49f75a5b0b7266378515af98db310cf6c772bf6e68bed01f38ee99b408042") exit 0; else exit 1}'
tar xfz reshape2_1.4.1.tar.gz
cd reshape2
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm reshape2 -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/dichromat_2.0-0.tar.gz
sha256sum dichromat_2.0-0.tar.gz | awk '{ if ($1 == "31151eaf36f70bdc1172da5ff5088ee51cc0a3db4ead59c7c38c25316d580dd1") exit 0; else exit 1}'
tar xfz dichromat_2.0-0.tar.gz
cd dichromat
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm dichromat -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/colorspace_1.2-6.tar.gz
sha256sum colorspace_1.2-6.tar.gz | awk '{ if ($1 == "ba3165c5b906edadcd1c37cad0ef58f780b0af651f3fdeb49fbb2dc825251679") exit 0; else exit 1}'
tar xfz colorspace_1.2-6.tar.gz
cd colorspace
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm colorspace -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/munsell_0.4.2.tar.gz
sha256sum munsell_0.4.2.tar.gz | awk '{ if ($1 == "84e787f58f626c52a1e3fc1201f724835dfa8023358bfed742e7001441f425ae") exit 0; else exit 1}'
tar xfz munsell_0.4.2.tar.gz
cd munsell
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm munsell -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/labeling_0.3.tar.gz
sha256sum labeling_0.3.tar.gz | awk '{ if ($1 == "0d8069eb48e91f6f6d6a9148f4e2dc5026cabead15dd15fc343eff9cf33f538f") exit 0; else exit 1}'
tar xfz labeling_0.3.tar.gz
cd labeling
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm labeling -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/scales_0.3.0.tar.gz
sha256sum scales_0.3.0.tar.gz | awk '{ if ($1 == "f4e1b98e3501b3a27b1a86ecc622a4653aff31c9f93248d7b5d428b03ebe6fce") exit 0; else exit 1}'
tar xfz scales_0.3.0.tar.gz
cd scales
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm scales -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/proto_0.3-10.tar.gz
sha256sum proto_0.3-10.tar.gz | awk '{ if ($1 == "d0d941bfbf247879b3510c8ef3e35853b1fbe83ff3ce952e93d3f8244afcbb0e") exit 0; else exit 1}'
tar xfz proto_0.3-10.tar.gz
cd proto
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm proto -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/MASS_7.3-44.tar.gz
sha256sum MASS_7.3-44.tar.gz | awk '{ if ($1 == "835fe22547222742fa84b8bf77774432abe3dff267932b8b8ed06de554f8e79b") exit 0; else exit 1}'
tar xfz MASS_7.3-44.tar.gz
cd MASS
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm MASS -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/ggplot2_1.0.1.tar.gz
sha256sum ggplot2_1.0.1.tar.gz | awk '{ if ($1 == "40248e6b31307787e44e45d806e7a33095844a9bbe864cc7583dd311b19c241d") exit 0; else exit 1}'
tar xfz ggplot2_1.0.1.tar.gz
cd ggplot2
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm ggplot2 -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/Formula_1.2-1.tar.gz
sha256sum Formula_1.2-1.tar.gz | awk '{ if ($1 == "5db1ef55119b299c9d291e1c5c08e2d51b696303daf4e7295c38ff5fc428360a") exit 0; else exit 1}'
tar xfz Formula_1.2-1.tar.gz
cd Formula
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm Formula -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/latticeExtra_0.6-26.tar.gz
sha256sum latticeExtra_0.6-26.tar.gz | awk '{ if ($1 == "0d1410f279d515a99c102824cc11ad2b024c86ee6af982cb45ea55739e06a09b") exit 0; else exit 1}'
tar xfz latticeExtra_0.6-26.tar.gz
cd latticeExtra
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm latticeExtra -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/cluster_2.0.3.tar.gz
sha256sum cluster_2.0.3.tar.gz | awk '{ if ($1 == "286671702b1ac4c4e918faa8b43cd7fe7561ce02ca5f62823be5f136d6674e0e") exit 0; else exit 1}'
tar xfz cluster_2.0.3.tar.gz
cd cluster
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm cluster -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/rpart_4.1-10.tar.gz
sha256sum rpart_4.1-10.tar.gz | awk '{ if ($1 == "c5ddaed288d38118876a94c7aa5000dce0070b8d736dba12de64a9cb04dc2d85") exit 0; else exit 1}'
tar xfz rpart_4.1-10.tar.gz
cd rpart
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm rpart -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/nnet_7.3-11.tar.gz
sha256sum nnet_7.3-11.tar.gz | awk '{ if ($1 == "979ed2fa4f9ec7c10e76188d41bc48f16fc90c3e59c3102714c85e53455ee54d") exit 0; else exit 1}'
tar xfz nnet_7.3-11.tar.gz
cd nnet
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm nnet -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/acepack_1.3-3.3.tar.gz
sha256sum acepack_1.3-3.3.tar.gz | awk '{ if ($1 == "3e2c3348a9657da2097e2fca18c7ebaebc44f3acd0491216bd5104edfd1e3e8f") exit 0; else exit 1}'
tar xfz acepack_1.3-3.3.tar.gz
cd acepack
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm acepack -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/foreign_0.8-66.tar.gz
sha256sum foreign_0.8-66.tar.gz | awk '{ if ($1 == "d7401e5fcab9ce6e697d3520dbb8475e229c30341c0004c4fa489c82aa4447a4") exit 0; else exit 1}'
tar xfz foreign_0.8-66.tar.gz
cd foreign
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm foreign -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/gridExtra_2.0.0.tar.gz
sha256sum gridExtra_2.0.0.tar.gz | awk '{ if ($1 == "27dc76f75eb08f99a4ab0f629a016250722368528ca6b515edb0b0339acbdea7") exit 0; else exit 1}'
tar xfz gridExtra_2.0.0.tar.gz
cd gridExtra
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm gridExtra -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_8_1/Hmisc_3.16-0.tar.gz
sha256sum Hmisc_3.16-0.tar.gz | awk '{ if ($1 == "4edc3903da63e25d747f34c33abf3e4e9a1f250580bbbab39fb192469738a30d") exit 0; else exit 1}'
tar xfz Hmisc_3.16-0.tar.gz
cd Hmisc
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm Hmisc -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2_1_8_2/DESeq2_1.8.2.tar.gz
sha256sum DESeq2_1.8.2.tar.gz | awk '{ if ($1 == "25fb91b73b033142069fde1413657e7ae8fbb1d801025eec4014a9760d9960ac") exit 0; else exit 1}'
tar xfz DESeq2_1.8.2.tar.gz
cd DESeq2
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm DESeq2 -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_6_1/gtools_3.4.1.tar.gz
sha256sum gtools_3.4.1.tar.gz | awk '{ if ($1 == "fa2b8351223369a13f4e922f13e8c836459a9522c775a455afd5e2b18941bb34") exit 0; else exit 1}'
tar xfz gtools_3.4.1.tar.gz
cd gtools
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm gtools -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_6_1/gdata_2.13.3.tar.gz
sha256sum gdata_2.13.3.tar.gz | awk '{ if ($1 == "554c973955a5d768359f56556effff6a7acd9e859d98ab13fa010df01fa16516") exit 0; else exit 1}'
tar xfz gdata_2.13.3.tar.gz
cd gdata
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm gdata -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_6_1/bitops_1.0-6.tar.gz
sha256sum bitops_1.0-6.tar.gz | awk '{ if ($1 == "9b731397b7166dd54941fb0d2eac6df60c7a483b2e790f7eb15b4d7b79c9d69c") exit 0; else exit 1}'
tar xfz bitops_1.0-6.tar.gz
cd bitops
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm bitops -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_6_1/caTools_1.17.1.tar.gz
sha256sum caTools_1.17.1.tar.gz | awk '{ if ($1 == "d32a73febf00930355cc00f3e4e71357412e0f163faae6a4bf7f552cacfe9af4") exit 0; else exit 1}'
tar xfz caTools_1.17.1.tar.gz
cd caTools
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm caTools -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_6_1/KernSmooth_2.23-13.tar.gz
sha256sum KernSmooth_2.23-13.tar.gz | awk '{ if ($1 == "3f5fbda9201ea0dab4b5d30a8b857460a929502fc07e3fadc87445c746ce3fe5") exit 0; else exit 1}'
tar xfz KernSmooth_2.23-13.tar.gz
cd KernSmooth
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm KernSmooth -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_6_1/gplots_2.14.2.tar.gz
sha256sum gplots_2.14.2.tar.gz | awk '{ if ($1 == "8cb2ef4309f44eb049f0a8761d3b2aaf636e0ec2323942ec0c27fd8b4912abf9") exit 0; else exit 1}'
tar xfz gplots_2.14.2.tar.gz
cd gplots
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm gplots -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2-1_2_10/getopt_1.20.0.tar.gz
sha256sum getopt_1.20.0.tar.gz | awk '{ if ($1 == "f920baa2a0ef7082155c8b666851af0c77534af8b2ca0cd067e7d56fdf3ec501") exit 0; else exit 1}'
tar xfz getopt_1.20.0.tar.gz
cd getopt
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm getopt -rf

wget --no-check-certificate https://github.com/bgruening/download_store/raw/master/DESeq2_1_8_2/rjson_0.2.14.tar.gz
sha256sum rjson_0.2.14.tar.gz | awk '{ if ($1 == "93d417f4eddb6fb7d679fbabb934b155de3965cf3d3e5ab03af69af5a0123357") exit 0; else exit 1}'
tar xfz rjson_0.2.14.tar.gz
cd rjson
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm rjson -rf

