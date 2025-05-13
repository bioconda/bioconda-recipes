#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/${PKG_NAME}/bin
mkdir -p $PREFIX/share/${PKG_NAME}/config
mkdir -p $PREFIX/share/${PKG_NAME}/dependencies

# 复制主脚本和其他文件
cp bin/HybSuite.sh $PREFIX/bin/
cp -r bin/*.py $PREFIX/share/${PKG_NAME}/bin/
cp -r bin/*.R $PREFIX/share/${PKG_NAME}/bin/
cp -r config/* $PREFIX/share/${PKG_NAME}/config/
cp -r dependencies/* $PREFIX/share/${PKG_NAME}/dependencies/

# 设置执行权限
chmod +x $PREFIX/bin/HybSuite.sh
chmod -R 777 $PREFIX/share/${PKG_NAME}/

# 创建符号链接
ln -s $PREFIX/bin/HybSuite.sh $PREFIX/bin/hybsuite

# 修正HybSuite.sh中的路径引用
sed -i "s|script_dir=.*|script_dir=\"$PREFIX/share/${PKG_NAME}/bin\"|g" $PREFIX/bin/HybSuite.sh
sed -i "s|config_dir=.*|config_dir=\"$PREFIX/share/${PKG_NAME}/config\"|g" $PREFIX/bin/HybSuite.sh
sed -i "s|dependencies_dir=.*|dependencies_dir=\"$PREFIX/share/${PKG_NAME}/dependencies\"|g" $PREFIX/bin/HybSuite.sh

# 创建post-link.sh文件来安装PhyloPyPruner
cat > $PREFIX/bin/.post-link.sh << 'EOF'
#!/bin/bash
set -e
"${PREFIX}/bin/pip" install --no-deps phylopypruner
EOF

chmod +x $PREFIX/bin/.post-link.sh