#!/bin/bash

# 获取并安装sse2neon.h
wget https://github.com/jserv/sse2neon/raw/master/sse2neon.h -O ${PREFIX}/include/sse2neon.h

# 修复头文件包含格式
sed -i 's/#include <emmintrin.h>/#include "sse2neon.h"/g' ksw.c
sed -i 's/#include "<sse2neon.h>"/#include "sse2neon.h"/g' ksw.c

# 设置编译环境
export C_INCLUDE_PATH=${PREFIX}/include:${C_INCLUDE_PATH}
export LIBRARY_PATH=${PREFIX}/lib:${LIBRARY_PATH}
export CFLAGS="${CFLAGS} -Wno-format-overflow -Wno-maybe-uninitialized"

# 根据不同系统进行编译
if [[ $(uname -s) == "Darwin" ]]; then
    make CC=$CC LIBS="$LDFLAGS -lm -lz -lpthread" INCLUDES="$CFLAGS" -j${CPU_COUNT}
else
    make CC=$CC LIBS="$LDFLAGS -lm -lz -lpthread -lrt" INCLUDES="$CFLAGS" -j${CPU_COUNT}
fi

# 安装程序
install -m 0755 paladin ${PREFIX}/bin
