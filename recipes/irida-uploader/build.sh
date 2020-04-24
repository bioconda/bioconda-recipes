#!/bin/bash
mkdir -p $PREFIX/bin

cp upload_run.py $PREFIX/bin/irida-uploader
cp -r iridauploader $PREFIX/bin

chmod +x $PREFIX/bin/irida-uploader
