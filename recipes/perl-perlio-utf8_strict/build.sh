#!/bin/bash

# 检测并配置xlocale兼容路径
if [ ! -f "/usr/include/xlocale.h" ]; then
    [ -f "/usr/include/locale.h" ] && \
    sudo ln -sf /usr/include/locale.h /usr/include/xlocale.h
fi

# 设置编译器包含路径
export C_INCLUDE_PATH=/usr/include:$C_INCLUDE_PATH

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
