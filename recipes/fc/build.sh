#!/bin/bash


# 编译源代码
#make

# 运行编译好的程序
#echo "运行程序..."
#./bin/fc-virus

echo "克隆代码库..."
git clone https://github.com/qdu-bioinfo/FC-Virus.git

# 进入目录
cd FC-Virus || { echo "进入目录失败"; exit 1; }

# 清理和编译
echo "清理旧文件并编译..."
if make clean && make; then
    echo "编译成功"
else
    echo "编译失败"
    echo "错误信息："
    make 2>&1 | tail -n 20  # 输出最后20行错误信息
    exit 1
fi

# 运行编译好的程序
echo "运行程序..."
chmod 755 ./bin/fc-virus
ls -l
conda list libstdcxx-ng
#conda install libgcc-ng libstdcxx-ng boost
ldd ./bin/fc-virus
conda search libstdcxx-ng

if ! ./fc-virus --help 2>&1; then
    echo "运行程序失败，错误信息为：$?"
    exit 1
fi
