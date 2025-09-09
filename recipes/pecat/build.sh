#!/bin/bash
set -ex

# 设置环境变量
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export PATH="${PATH}:${PREFIX}/bin"

# 架构优化
case $(uname -m) in    
    aarch64|arm*)         
	CFLAGS="${CFLAGS} -march=armv8-a+simd -DKSW_CPU_DISPATCH=0"         
	CFLAGS="${CFLAGS} -mtune=cortex-a72"  # 添加ARM调优参数         
	;;     
    *)         
	CFLAGS="${CFLAGS} -march=native"         
	;; 
esac 


# 标准化ksw2库编译
KSW2_DIR="${SRC_DIR}/thirdparty/ksw2"
[ -d "${KSW2_DIR}" ] || { echo "错误：找不到ksw2目录"; exit 1; }

cat > "${KSW2_DIR}/Makefile" <<'EOF'
CC ?= gcc
AR ?= ar
CFLAGS += -Wall -O2

OBJS = ksw2_gg.o ksw2_extz.o ksw2_extd.o

libksw2.a: $(OBJS)
	$(AR) -rc $@ $^

%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o *.a
EOF


# 编译ksw2库
cd "${KSW2_DIR}" || exit 1
make clean || true
make CC="${CC}" AR="${AR}" CFLAGS="${CFLAGS}" libksw2.a || exit 1

# 主项目编译
cd "${SRC_DIR}" || exit 1
make -j$(nproc) CFLAGS="${CFLAGS}" || \
make CFLAGS="${CFLAGS}" || exit 1

# 安装
install -d "${PREFIX}/bin" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin"
cp -r build/bin/* "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/"

cat > "${PREFIX}/bin/pecat.pl" <<EOF
#!/bin/bash
${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/pecat.pl "\$@"
EOF
chmod +x "${PREFIX}/bin/pecat.pl"
