#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/proteomes2structs

cp bin/proteomes2structs $PREFIX/bin/
cp src/proteomes2structs.sh $PREFIX/share/proteomes2structs/

chmod +x $PREFIX/bin/proteomes2structs
chmod +x $PREFIX/share/proteomes2structs/proteomes2structs.sh
