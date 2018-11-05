#!/bin/bash
env
sed 's/CPROGNAME/diprofile/g' CMakeLists.template > CMakeLists.txt

mkdir -p  build
cd build

SEQAN_INCLUDE_PATH="$CONDA_DEFAULT_ENV/include/"
CMAKE_PREFIX_PATH="$CONDA_DEFAULT_ENV/share/cmake/seqan"
cmake  ../ -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH" -DSEQAN_INCLUDE_PATH="$SEQAN_INCLUDE_PATH" -DCMAKE_BUILD_TYPE=Release 
make

echo  ">line1" > test.fasta
echo  "AAAATGCGTAATGGTGGCAAACTCGTAGGCT" >> test.fasta
echo  ">line2" >> test.fasta
echo  "ctAAATGCtTAATGGTCGCAACGGAATTGCC" >> test.fasta
echo  ">line3" >> test.fasta
echo  "AAAATGCGTAATTGTGGCAGGGAATTCCGTA" >> test.fasta
echo  ">line4" >> test.fasta
echo  "GAaATGCGTAATGGTGGCAATTAAGCTAGTG" >> test.fasta
echo  ">line5" >> test.fasta
echo  "GGCaaTGCGTAATGGTAGTTATGGAATCGGT" >> test.fasta
# run on small fasta 
./diprofile test.fasta -sl 30 -di AA  
./diprofile test.fasta -sl 30 -c -di AA

cp diprofile $PREFIX/bin/dnp-diprofile
