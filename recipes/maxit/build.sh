#!/bin/bash

# 環境変数の設定
export RCSBROOT="$PREFIX"

# ソースディレクトリに移動
cd maxit-v${PKG_VERSION}-prod-src

# ビルド用にソースコードを修正
cd maxit-v10.1/src
sed -i.bak 's|rcsbroot = getenv("RCSBROOT")|rcsbroot = "'${PREFIX}'"|' maxit.C process_entry.C generate_assembly_cif_file.C
cd ../cifparse-obj-v7.0
sed -i.bak 's/mv /install /' Makefile
cd ../../

# アプリケーションのビルド
make

# 必要なバイナリデータの生成
make binary

# バイナリとデータをインストール
install -d "$PREFIX/bin"  # 必要なディレクトリを作成
install bin/* "$PREFIX/bin"  # バイナリをコピー
install -d "$PREFIX/data"
install -m 644 data/* "$PREFIX/data"  # データをコピー
