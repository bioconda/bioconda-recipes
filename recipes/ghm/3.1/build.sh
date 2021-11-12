
# mct -- 2017/10/08
# - Outdated source, external static functions doesn't always work with inline
# - Replace inline with normal if make errors:
sed -i "s|inline double genrand_close1_open2(void)|double genrand_close1_open2(void)|" src/dSFMT.c


# Patch for cc under OSX, return value in non-void function
#perl -0777 -i -pe 's/\s+num_w_pos = pos_b - pos_a\;\n\s+return\;/\n\tnum_w_pos = pos_b - pos_a\;\n\treturn 0\;/igs' src/newcombo.c

if [[ ${target_platform} =~ linux.* ]] ; then
    sys=-D_SYS_OSF
elif [[ ${target_platform} =~ osx.* ]] ; then
    sys=-D_SYS_OSX
fi
make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" SYS="${sys}"

install -d "${PREFIX}/bin"
install ./ghm "${PREFIX}/bin/"
