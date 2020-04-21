#!/bin/bash
mkdir -p $PREFIX/bin

cp iridauploader/upload_run.py $PREFIX/bin/irida-uploader
cp -r iridauploader/config $PREFIX/bin
cp -r iridauploader/core $PREFIX/bin
cp -r iridauploader/api $PREFIX/bin
cp -r iridauploader/model $PREFIX/bin
cp -r iridauploader/parsers $PREFIX/bin
cp -r iridauploader/progress $PREFIX/bin

chmod +x $PREFIX/bin/irida-uploader
