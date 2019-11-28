#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

## Dependencies
#echo $PWD && ls -R $PWD &&
#cd $SRC_DIR;
#rmdir bonsai && wget https://github.com/dnbaker/bonsai/archive/v0.2.3.tar.gz && tar -xvf v0.2.3.tar.gz && mv bonsai-0.2.3 bonsai && rm v0.2.3.tar.gz;
#rmdir sketch && wget https://github.com/dnbaker/sketch/archive/v0.9.0.tar.gz && tar -xvf v0.9.0.tar.gz && mv sketch-0.9.0 sketch && rm v0.9.0.tar.gz;
#cd sketch && wget https://github.com/kimwalisch/libpopcnt/archive/v2.2.tar.gz && rmdir libpopcnt && tar -xvf v2.2.tar.gz && mv libpopcnt-2.2 libpopcnt && rm v2.2.tar.gz;
#rmdir compact_vector; git clone https://github.com/gmarcais/compact_vector && cd compact_vector && git reset --hard e3bbd15290ac76b9732fab7b2d2a5c83ae01595e && cd ..;
#rmdir vec; wget https://github.com/dnbaker/vec/archive/v0.1.tar.gz && tar -xvf v0.1.tar.gz && mv vec-0.1 vec && rm v0.1.tar.gz;
#rmdir aesctr; wget https://github.com/dnbaker/aesctr/archive/v0.1.tar.gz && tar -xvf v0.1.tar.gz && mv aesctr-0.1 aesctr && rm v0.1.tar.gz;
#rmdir flat_hash_map; git clone https://github.com/skarupke/flat_hash_map && cd flat_hash_map && git reset --hard 2c4687431f978f02a3780e24b8b701d22aa32d9c && cd ..;
#rmdir xxHash; wget https://github.com/Cyan4973/xxHash/archive/v0.7.2.tar.gz && tar -xvf v0.7.2.tar.gz && mv xxHash-0.7.2 xxHash && rm v0.7.2.tar.gz;
#cd ..;
#rmdir khset; wget https://github.com/dnbaker/khset/archive/v0.1.tar.gz && tar -xvf v0.1.tar.gz && mv khset-0.1 khset && rm v0.1.tar.gz;
#cd bonsai;
#rmdir kspp; wget https://github.com/dnbaker/kspp/archive/v0.1.tar.gz && tar -xvf v0.1.tar.gz && mv kspp-0.1 kspp && rm v0.1.tar.gz;
#rmdir clhash; git clone https://github.com/lemire/clhash && cd clhash && git reset --hard 742f81a66c8e2ae7889d1bc4c4b4d8734bdcd5af && cd ..;
#rmdir klib; git clone https://github.com/attractivechaos/klib && cd klib && git reset --hard f719aad5fa273424fab4b0d884d68375b7cc2520 && cd ..;
#rmdir lazy; wget https://github.com/dnbaker/lazy/archive/v0.1.tar.gz && tar -xvf v0.1.tar.gz && mv lazy-0.1 lazy && rm v0.1.tar.gz;
#rmdir linear; wget https://github.com/dnbaker/linear/archive/v0.1.tar.gz && tar -xvf v0.1.tar.gz && mv linear-0.1 linear && rm v0.1.tar.gz;
#rmdir pdqsort; git clone https://github.com/orlp/pdqsort && cd pdqsort && git reset --hard 08879029ab8dcb80a70142acb709e3df02de5d37 && cd ..;
#rmdir circularqueue; wget https://github.com/dnbaker/circularqueue/archive/v0.1.tar.gz && tar -xvf v0.1.tar.gz && mv circularqueue-0.1 circularqueue && rm v0.1.tar.gz;
#rmdir rollinghashcpp; git clone https://github.com/dnbaker/rollinghashcpp && cd rollinghashcpp &&  git reset --hard e68381300c074cbc6609a32367b9b7d93c65702e && cd ..;
#rmdir ntHash; wget https://github.com/bcgsc/ntHash/archive/v1.0.4.tar.gz && tar -xvf v1.0.4.tar.gz && mv ntHash-1.0.4 ntHash && rm v1.0.4.tar.gz;
#rmdir zlib; wget https://github.com/madler/zlib/archive/v1.2.11.tar.gz && tar -xvf v1.2.11.tar.gz && mv zlib-1.2.11 zlib;
#cd ..;
#rmdir distmat; wget https://github.com/dnbaker/distmat/archive/v0.1.tar.gz && tar -xvf v0.1.tar.gz && mv distmat-0.1 distmat && rm v0.1.tar.gz;

make
make install PREFIX=$PREFIX
