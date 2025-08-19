export HAS_GTEST=0

if [ $target_platform == "linux-aarch64" ];then

# fix build number in config
sed -i.bak 's/VERSION_STRING.*/VERSION_STRING="${PKG_VERSION}"/' config.mk

sed -i.bak 's%-mavx2% %g' config.mk
sed -i.bak 's%-msse4.2% %g' config.mk

sed -i '9c #define _TARGET_ARM_'   ./thirdparty/dragen/src/host/metrics/public/mapping_stats.hpp
sed -i '21c #include "sse2neon.h"' ./thirdparty/dragen/src/host/metrics/public/mapping_stats.hpp
sed -i '37c #include "sse2neon.h"' ./thirdparty/sswlib/ssw/ssw.hpp
sed -i '18c #include "sse2neon.h"' ./src/include/align/AlignmentRescue.hpp
sed -i '15c #include "sse2neon.h"' ./src/lib/align/AlignmentRescue.cpp
sed -i '15c #include "sse2neon.h"' ./src/lib/sequences/Read.cpp
sed -i '31c #include "sse2neon.h"' ./thirdparty/sswlib/ssw/ssw_avx2.cpp
sed -i '35c #include "sse2neon.h"' ./thirdparty/sswlib/ssw/ssw_internal.hpp
sed -i '33c #include "sse2neon.h"' ./thirdparty/sswlib/ssw/ssw.cpp
sed -i 's%getHostVersion(0)%getHostVersion()%g' ./thirdparty/dragen/src/common/hash_generation/gen_hash_table.c


sed -i '542a #if defined(__aarch64__)  // ARM 64 位架构' ./thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '543a static inline uint64_t RDTSC() { '          ./thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '544a uint64_t val;'                              ./thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '545a __asm__ __volatile__ ('			 ./thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '546a "mrs %0, cntvct_el0"' 			 ./thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '547a : "=r" (val)'				 ./thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '548a );'					 ./thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '549a return val;'  				 ./thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '550a }'		       				 ./thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '551a #elif defined(__x86_64__) || defined(__i386__)  // x86 架构' thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '558a #else' 				         ./thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '559a ///#error "Unsupported architecture (RDTSC not implemented)"' thirdparty/dragen/src/common/hash_generation/hash_table.c
sed -i '560a #endif' 					 ./thirdparty/dragen/src/common/hash_generation/hash_table.c

sed -i '/#include <memory>/a #include <cstdint>'         ./stubs/dragen/src/host/metrics/public/run_stats.hpp

sed -i 's/__m256i\*/void*/g'  				 ./thirdparty/sswlib/ssw/ssw_internal.hpp

sed -i '/CXXFLAGS +=/ s/$/ -march=armv8-a /'   ./make/lib.mk

git clone https://github.com/DLTcollab/sse2neon.git
cp sse2neon/sse2neon.h ./thirdparty/dragen/src/host/metrics/public
cp sse2neon/sse2neon.h ./thirdparty/sswlib/ssw
cp sse2neon/sse2neon.h ./src/include/align
cp sse2neon/sse2neon.h ./src/lib/align
cp sse2neon/sse2neon.h ./src/lib/sequences
echo "pwd:----------------------------$PWD----------------"
make CXX=$CXX CC=$CC CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS -march=armv8-a" CXXFLAGS="-march=armv8-a"
else
make CXX=$CXX CC=$CC CXXFLAGS="$CXXFLAGS" CFLAGS="$CFLAGS"
fi

mkdir -p "${PREFIX}/bin"
mv build/release/dragen-os ${PREFIX}/bin/
