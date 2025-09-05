#!/bin/bash

# 设置编译环境变量
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export PATH="${PATH}:${PREFIX}/bin"

# 强化ksw2库编译修复
KSW2_MAKEFILE="${SRC_DIR}/thirdparty/ksw2/Makefile"

# 标准化目标文件命名
sed -i 's/ksw2_gg2_sse/ksw2_gg/g' "${KSW2_MAKEFILE}"
sed -i 's/ksw2_extz2_sse/ksw2_extz/g' "${KSW2_MAKEFILE}"
sed -i 's/ksw2_extd2_sse/ksw2_extd/g' "${KSW2_MAKEFILE}"

# 修正编译规则
sed -i '/^libksw2.a:/c\libksw2.a: ksw2_gg.o ksw2_extz.o ksw2_extd.o\n\t$(AR) -rc $@ $^' "${KSW2_MAKEFILE}"
sed -i '/%.o: %.c/a\\t@mkdir -p $(@D)' "${KSW2_MAKEFILE}"


# 1. 确保Makefile存在且路径正确
KSW2_DIR="${SRC_DIR}/thirdparty/ksw2"
if [ ! -f "${KSW2_DIR}/Makefile" ]; then
    echo "错误：找不到Makefile文件" >&2
    exit 1
fi

# 2. 强制重建编译规则
cat > "${KSW2_DIR}/Makefile" <<'EOF'
CC ?= gcc
AR ?= ar
CFLAGS += -Wall -O2

OBJS = ksw2_gg.o ksw2_extz.o ksw2_extd.o

libksw2.a: $(OBJS)
	$(AR) -rc $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o *.a
EOF

# 3. 架构特定优化
case $(uname -m) in
    aarch64|arm*)
        sed -i 's/-O2/-O2 -march=armv8-a+simd/' "${KSW2_DIR}/Makefile"
        ;;
esac

# 4. 分步编译验证
cd "${KSW2_DIR}" || exit 1
make clean && \
make CC="${CC}" AR="${AR}" CFLAGS="${CFLAGS}" libksw2.a || exit 1

# 5. 验证库文件
if [ ! -f "${KSW2_DIR}/libksw2.a" ]; then
    echo "错误：libksw2.a生成失败" >&2
    exit 1
fi


# 架构优化
case $(uname -m) in
    aarch64|arm*)
        sed -i 's/-march=native/-march=armv8-a+simd/' "${KSW2_MAKEFILE}"
        export CFLAGS="${CFLAGS} -DKSW_CPU_DISPATCH=0"
        ;;
esac

# 安全编译函数
function safe_make() {
    for i in {1..3}; do
        make "$@" && return 0
        make clean
        echo "编译失败，尝试第$((i+1))次..."
    done
    return 1
}

# 执行编译
cd "${SRC_DIR}/thirdparty/ksw2" && \
safe_make CC="${CC}" CFLAGS="${CFLAGS}" libksw2.a || exit 1

# 主项目编译
cd "${SRC_DIR}" && make -j$(nproc) CFLAGS="${CFLAGS}" || make CFLAGS="${CFLAGS}"

# 安装
mkdir -p "${PREFIX}/bin" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin"
cp -r build/bin/* "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/"

cat > "${PREFIX}/bin/pecat.pl" <<EOF
#!/bin/bash
${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/bin/pecat.pl "\$@"
EOF
chmod +x "${PREFIX}/bin/pecat.pl"

