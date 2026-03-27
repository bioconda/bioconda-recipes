#!/bin/bash
set -x -e

RM_DIR=${PREFIX}/share/pneumo-typer
mkdir -p ${RM_DIR}
mkdir -p ${PREFIX}/bin
ls -a

# 关键修改：仅复制pneumo-typer-2.0.1目录下的内容到目标路径
cp -r $SRC_DIR/pneumo-typer-v2.0.1/* ${RM_DIR}/

# 复制其他必要的构建文件（如果这些文件在顶层目录）
cp $SRC_DIR/build_env_setup.sh ${RM_DIR}
cp $SRC_DIR/conda_build.sh ${RM_DIR}
cp $SRC_DIR/metadata_conda_debug.yaml ${RM_DIR}

# Set a executable file for Pneumo-Typer.pl
cat <<END >>${PREFIX}/bin/pneumo-typer
#!/bin/bash
perl ${RM_DIR}/pneumo-typer.pl \$@
END
# Set a executable file for update_mlstdb_cgmlstdb.pl
cat <<END >>${PREFIX}/bin/update_mlstdb_cgmlstdb
#!/bin/bash
perl ${RM_DIR}/update_mlstdb_cgmlstdb.pl \$@
END

chmod a+x ${PREFIX}/bin/pneumo-typer
chmod a+x ${PREFIX}/bin/update_mlstdb_cgmlstdb