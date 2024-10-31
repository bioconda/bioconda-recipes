#!/bin/bash

pwd
conda info --envs
conda env list
echo $PATH
# 编译源代码
#make

# 运行编译好的程序
#echo "运行程序..."
#./bin/fc-virus

echo "克隆代码库..."
git clone https://github.com/qdu-bioinfo/FC-Virus.git
pwd
# 进入目录
cd FC-Virus/code || { echo "进入目录失败"; exit 1; }

# 清理和编译
echo "清理旧文件并编译..."
#make clean && make
ls -l
if ! g++ -o FC-Virus GeneralSet.cpp ReadUtility.cpp KmerUtility.cpp KmerHash.cpp HomoKmer.cpp Consensus.cpp FC-Virus.cpp; then
    echo "编译失败，错误信息如下："
    # 上一条命令的错误信息会自动输出
    exit 1
else
    echo "编译成功"
fi


# 运行编译好的程序
echo "运行程序..."
ls -l
if ! ./FC-Virus --help 2>&1; then
    echo "运行程序失败，错误信息为：$?"
    exit 1
fi

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
