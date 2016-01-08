#!/bin/sh
wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/BiocGenerics_0.12.1.tar.gz
sha256sum BiocGenerics_0.12.1.tar.gz | awk '{ if ($1 == "d451f2c72c46a7b5fa6dd252a207ba72f0a5a86d1bfc95408935f079efa85f77") exit 0; else exit 1}'
tar xfz BiocGenerics_0.12.1.tar.gz
cd BiocGenerics
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm BiocGenerics -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/S4Vectors_0.4.0.tar.gz
sha256sum S4Vectors_0.4.0.tar.gz | awk '{ if ($1 == "8a696633faf34458580ca851a77eb55cfa60e454a5412216c8dd3c19fac46b78") exit 0; else exit 1}'
tar xfz S4Vectors_0.4.0.tar.gz
cd S4Vectors
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm S4Vectors -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/IRanges_2.0.1.tar.gz
sha256sum IRanges_2.0.1.tar.gz | awk '{ if ($1 == "6c26fcb89570f869fe476688d59e99f4c4eb8358a4f8a16d00f77ab04a9c3db9") exit 0; else exit 1}'
tar xfz IRanges_2.0.1.tar.gz
cd IRanges
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm IRanges -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/GenomeInfoDb_1.2.4.tar.gz
sha256sum GenomeInfoDb_1.2.4.tar.gz | awk '{ if ($1 == "459d8904e30999435f7dd2ce40fc9a1b076982f798a6d2fb752d0311a7bcbd4b") exit 0; else exit 1}'
tar xfz GenomeInfoDb_1.2.4.tar.gz
cd GenomeInfoDb
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm GenomeInfoDb -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/XVector_0.6.0.tar.gz
sha256sum XVector_0.6.0.tar.gz | awk '{ if ($1 == "ea61b364a647b590a566c69429e9eb9d10296825bac2d8168881dd8404d8ba14") exit 0; else exit 1}'
tar xfz XVector_0.6.0.tar.gz
cd XVector
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm XVector -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/GenomicRanges_1.18.4.tar.gz
sha256sum GenomicRanges_1.18.4.tar.gz | awk '{ if ($1 == "1ff768364df263f7c55b31488b8718f173ae06f4d3bc6f49d4f24ccf300f4aa9") exit 0; else exit 1}'
tar xfz GenomicRanges_1.18.4.tar.gz
cd GenomicRanges
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm GenomicRanges -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/RColorBrewer_1.1-2.tar.gz
sha256sum RColorBrewer_1.1-2.tar.gz | awk '{ if ($1 == "f3e9781e84e114b7a88eb099825936cc5ae7276bbba5af94d35adb1b3ea2ccdd") exit 0; else exit 1}'
tar xfz RColorBrewer_1.1-2.tar.gz
cd RColorBrewer
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm RColorBrewer -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/lattice_0.20-30.tar.gz
sha256sum lattice_0.20-30.tar.gz | awk '{ if ($1 == "528ce0a6378334de47e11a1a7efe0f4b3b1c8b44ec8e3f0720bd9e5b122d2881") exit 0; else exit 1}'
tar xfz lattice_0.20-30.tar.gz
cd lattice
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm lattice -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/nlme_3.1-120.tar.gz
sha256sum nlme_3.1-120.tar.gz | awk '{ if ($1 == "4cd65b2187d6155652d8725f62086641da373f23f3bce4170ace92705cb628ca") exit 0; else exit 1}'
tar xfz nlme_3.1-120.tar.gz
cd nlme
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm nlme -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/Matrix_1.1-5.tar.gz
sha256sum Matrix_1.1-5.tar.gz | awk '{ if ($1 == "b23ea59a5218be916a3e6ac4d5f573c5e7921b1eca9a2ed918f2d8f8ef520b4f") exit 0; else exit 1}'
tar xfz Matrix_1.1-5.tar.gz
cd Matrix
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm Matrix -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/mgcv_1.8-5.tar.gz
sha256sum mgcv_1.8-5.tar.gz | awk '{ if ($1 == "dcad548be9efbff8737e54082dde5a20cac79f81037eb79586ad68bf403f7c8c") exit 0; else exit 1}'
tar xfz mgcv_1.8-5.tar.gz
cd mgcv
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm mgcv -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/Biobase_2.26.0.tar.gz
sha256sum Biobase_2.26.0.tar.gz | awk '{ if ($1 == "c481a23e57762d969b225d0fa2e72cbe72e0ce037422d89bafcc8b7527561b9c") exit 0; else exit 1}'
tar xfz Biobase_2.26.0.tar.gz
cd Biobase
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm Biobase -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/DBI_0.3.1.tar.gz
sha256sum DBI_0.3.1.tar.gz | awk '{ if ($1 == "1c26535720f146fae8cc9ef6e190619967abf296706a5b5a1e8242cbbb5a4576") exit 0; else exit 1}'
tar xfz DBI_0.3.1.tar.gz
cd DBI
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm DBI -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/RSQLite_1.0.0.tar.gz
sha256sum RSQLite_1.0.0.tar.gz | awk '{ if ($1 == "8e0cfca19afbc61f40c6d86018cd723a7e00f16d0944c4637f07a18fb6d76121") exit 0; else exit 1}'
tar xfz RSQLite_1.0.0.tar.gz
cd RSQLite
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm RSQLite -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/AnnotationDbi_1.28.1.tar.gz
sha256sum AnnotationDbi_1.28.1.tar.gz | awk '{ if ($1 == "214a293286af854001ce46b9d866ea5b3fbc4e6b8383be0952f63491e4f6171c") exit 0; else exit 1}'
tar xfz AnnotationDbi_1.28.1.tar.gz
cd AnnotationDbi
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm AnnotationDbi -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/XML_3.98-1.1.tar.gz
sha256sum XML_3.98-1.1.tar.gz | awk '{ if ($1 == "947318e0e0d272bcd57244999d897d6f7b2624554fdf451f8c3c0461c8313159") exit 0; else exit 1}'
tar xfz XML_3.98-1.1.tar.gz
cd XML
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm XML -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/xtable_1.7-4.tar.gz
sha256sum xtable_1.7-4.tar.gz | awk '{ if ($1 == "47629a31185591be30b13ae3a656fc24360760996975e292f4fa7954c0257dbb") exit 0; else exit 1}'
tar xfz xtable_1.7-4.tar.gz
cd xtable
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm xtable -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/annotate_1.44.0.tar.gz
sha256sum annotate_1.44.0.tar.gz | awk '{ if ($1 == "c191767f5876f8e44a82779749237e91f1e99b3dc6b8e93fe7a8c3e43d91b3ca") exit 0; else exit 1}'
tar xfz annotate_1.44.0.tar.gz
cd annotate
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm annotate -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/survival_2.38-1.tar.gz
sha256sum survival_2.38-1.tar.gz | awk '{ if ($1 == "f5b90925b7f4fd23ba99fb44b713ffe3b6768bfe7cb81037b9f0d615a051004f") exit 0; else exit 1}'
tar xfz survival_2.38-1.tar.gz
cd survival
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm survival -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/genefilter_1.48.1.tar.gz
sha256sum genefilter_1.48.1.tar.gz | awk '{ if ($1 == "31356f8eabecd6b4fe6124edcf9cd6b258481ff124061d709f49cb10f29691f6") exit 0; else exit 1}'
tar xfz genefilter_1.48.1.tar.gz
cd genefilter
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm genefilter -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/sva_3.12.0.tar.gz
sha256sum sva_3.12.0.tar.gz | awk '{ if ($1 == "53afc52973093a8a853cfa5e1ea4c03ca51bb744f8917b520efb8f429d8054f4") exit 0; else exit 1}'
tar xfz sva_3.12.0.tar.gz
cd sva
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm sva -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/limma_3.22.6.tar.gz
sha256sum limma_3.22.6.tar.gz | awk '{ if ($1 == "011131ed104f5be2eed7d7387877e2fe70c1ac72c1052de12cd2284cb61ce2b3") exit 0; else exit 1}'
tar xfz limma_3.22.6.tar.gz
cd limma
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm limma -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/zlibbioc_1.12.0.tar.gz
sha256sum zlibbioc_1.12.0.tar.gz | awk '{ if ($1 == "3a6738f0e2f341c4d511d3e230823c8494e1d65ab528aaa73d4507c7e338fa16") exit 0; else exit 1}'
tar xfz zlibbioc_1.12.0.tar.gz
cd zlibbioc
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm zlibbioc -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/Biostrings_2.34.1.tar.gz
sha256sum Biostrings_2.34.1.tar.gz | awk '{ if ($1 == "b00af8f8eb1dbafa4e0ab25b571fa0a9484376c761b4de949eb6bbb7d41bd0cd") exit 0; else exit 1}'
tar xfz Biostrings_2.34.1.tar.gz
cd Biostrings
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm Biostrings -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/bitops_1.0-6.tar.gz
sha256sum bitops_1.0-6.tar.gz | awk '{ if ($1 == "9b731397b7166dd54941fb0d2eac6df60c7a483b2e790f7eb15b4d7b79c9d69c") exit 0; else exit 1}'
tar xfz bitops_1.0-6.tar.gz
cd bitops
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm bitops -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/RCurl_1.95-4.5.tar.gz
sha256sum RCurl_1.95-4.5.tar.gz | awk '{ if ($1 == "365c582a6da2ef22f8d1bcbbeafe8478ed31de17b0890f740a3e2960620f1382") exit 0; else exit 1}'
tar xfz RCurl_1.95-4.5.tar.gz
cd RCurl
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm RCurl -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/Rsamtools_1.18.2.tar.gz
sha256sum Rsamtools_1.18.2.tar.gz | awk '{ if ($1 == "c845acbc05ff87a12aec1162fe687dda1a043d3e2efa5c08902c006b1ef5f4a6") exit 0; else exit 1}'
tar xfz Rsamtools_1.18.2.tar.gz
cd Rsamtools
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm Rsamtools -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/codetools_0.2-10.tar.gz
sha256sum codetools_0.2-10.tar.gz | awk '{ if ($1 == "329125c0f60092bad43569823fc9cda2a010e3abe82c27030afae23a4970383e") exit 0; else exit 1}'
tar xfz codetools_0.2-10.tar.gz
cd codetools
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm codetools -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/iterators_1.0.7.tar.gz
sha256sum iterators_1.0.7.tar.gz | awk '{ if ($1 == "1bf74e5a5603b2b2d3deecb801ca1796e2b2c3f08c488c497725c5cb205798ff") exit 0; else exit 1}'
tar xfz iterators_1.0.7.tar.gz
cd iterators
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm iterators -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/foreach_1.4.2.tar.gz
sha256sum foreach_1.4.2.tar.gz | awk '{ if ($1 == "d4fd8f090029d9b9168ae415e6ab13ef017f06f1879488a2e0af4bcfd999ff24") exit 0; else exit 1}'
tar xfz foreach_1.4.2.tar.gz
cd foreach
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm foreach -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/checkmate_1.5.1.tar.gz
sha256sum checkmate_1.5.1.tar.gz | awk '{ if ($1 == "0f837be7b92ccc7e2ed6930f342cfaab0213d2df2b82052a4788c8a399bd9c04") exit 0; else exit 1}'
tar xfz checkmate_1.5.1.tar.gz
cd checkmate
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm checkmate -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/BBmisc_1.9.tar.gz
sha256sum BBmisc_1.9.tar.gz | awk '{ if ($1 == "4b7fd5c6c1358a7e4c32c10237aa6f3f5279585afef83b0ffa1b3fc74c5f3006") exit 0; else exit 1}'
tar xfz BBmisc_1.9.tar.gz
cd BBmisc
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm BBmisc -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/brew_1.0-6.tar.gz
sha256sum brew_1.0-6.tar.gz | awk '{ if ($1 == "d70d1a9a01cf4a923b4f11e4374ffd887ad3ff964f35c6f9dc0f29c8d657f0ed") exit 0; else exit 1}'
tar xfz brew_1.0-6.tar.gz
cd brew
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm brew -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/digest_0.6.8.tar.gz
sha256sum digest_0.6.8.tar.gz | awk '{ if ($1 == "3062422c2ca917e52749464d63084a0d3cc061f59083f069280ec26336ce2f55") exit 0; else exit 1}'
tar xfz digest_0.6.8.tar.gz
cd digest
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm digest -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/fail_1.2.tar.gz
sha256sum fail_1.2.tar.gz | awk '{ if ($1 == "9fa037f5bff4ad3821ef1af4fe2986f2900cfa9a69d11f7a800a081cc359fb77") exit 0; else exit 1}'
tar xfz fail_1.2.tar.gz
cd fail
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm fail -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/base64enc_0.1-2.tar.gz
sha256sum base64enc_0.1-2.tar.gz | awk '{ if ($1 == "05fed8fde229fce48f5b9cd34f3bf92f2ca63d6038ba7cb9d37a2904e83e4b34") exit 0; else exit 1}'
tar xfz base64enc_0.1-2.tar.gz
cd base64enc
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm base64enc -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/sendmailR_1.2-1.tar.gz
sha256sum sendmailR_1.2-1.tar.gz | awk '{ if ($1 == "04feb08c6c763d9c58b2db24b1222febe01e28974eac4fe87670be6fb9bff17c") exit 0; else exit 1}'
tar xfz sendmailR_1.2-1.tar.gz
cd sendmailR
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm sendmailR -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/stringr_0.6.2.tar.gz
sha256sum stringr_0.6.2.tar.gz | awk '{ if ($1 == "c3fc9c71d060ad592d2cfc51c36ab2f8e5f8cf9a25dfe42c637447dd416b6737") exit 0; else exit 1}'
tar xfz stringr_0.6.2.tar.gz
cd stringr
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm stringr -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/BatchJobs_1.5.tar.gz
sha256sum BatchJobs_1.5.tar.gz | awk '{ if ($1 == "97583c7ddeb43a5361a9b45eab8b47a166077521c6963507e0155820690e44a9") exit 0; else exit 1}'
tar xfz BatchJobs_1.5.tar.gz
cd BatchJobs
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm BatchJobs -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/BiocParallel_1.0.3.tar.gz
sha256sum BiocParallel_1.0.3.tar.gz | awk '{ if ($1 == "339c7c8285637afafa0f3ca3d429ef002df5da1653490984cd64662f7cabf71f") exit 0; else exit 1}'
tar xfz BiocParallel_1.0.3.tar.gz
cd BiocParallel
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm BiocParallel -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/GenomicAlignments_1.2.1.tar.gz
sha256sum GenomicAlignments_1.2.1.tar.gz | awk '{ if ($1 == "eea049da0427d04a65c0a8b41a41ad1fc679a174e94b0879d5035d676e6ae3f0") exit 0; else exit 1}'
tar xfz GenomicAlignments_1.2.1.tar.gz
cd GenomicAlignments
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm GenomicAlignments -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/rtracklayer_1.26.2.tar.gz
sha256sum rtracklayer_1.26.2.tar.gz | awk '{ if ($1 == "c0284805d84f83f6189dc5a58461ea9ace8ec43dc301b0b317f4c3b493bf8bdb") exit 0; else exit 1}'
tar xfz rtracklayer_1.26.2.tar.gz
cd rtracklayer
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm rtracklayer -rf

wget --no-check-certificate https://depot.galaxyproject.org/package/noarch/ballgown_1.0.3.tar.gz
sha256sum ballgown_1.0.3.tar.gz | awk '{ if ($1 == "f79f0db8d9aa7a3c56feb1034dfd4f8fccb4aa4f962c88aebdd1cac728b19698") exit 0; else exit 1}'
tar xfz ballgown_1.0.3.tar.gz
cd ballgown
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
cd .. && rm ballgown -rf

