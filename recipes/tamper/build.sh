#!/bin/bash

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/share/tamper/
mkdir -p ${PREFIX}/share/tamper/src/
mkdir -p ${PREFIX}/share/tamper/checkpoints/trained
cp -r src/. ${PREFIX}/share/tamper/src/
cp -r checkpoints/trained/. ${PREFIX}/share/tamper/checkpoints/trained
ls ${PREFIX}/share/tamper/src/

#This allows src code to be executbale for user and group
chmod -R u+x ${PREFIX}/share/tamper/src/
chmod -R g+x ${PREFIX}/share/tamper/src/

ls -lah ${PREFIX}/share/tamper/src/

#Adding python executable for the script to work
echo "#!/bin/bash" > ${PREFIX}/bin/predict_tAMPer
echo "python ${PREFIX}/share/tamper/src/predict_tAMPer.py \"\$@\"" >> ${PREFIX}/bin/predict_tAMPer

echo "#!/bin/bash" > ${PREFIX}/bin/train_tAMPer.py
echo "python ${PREFIX}/share/tamper/src/train_tAMPer.py \"\$@\"" >> ${PREFIX}/bin/train_tAMPer

#Checking if files are copied within bin
echo "Files in ${PREFIX}/bin/:"
ls -l ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/predict_tAMPer
chmod +x ${PREFIX}/bin/train_tAMPer

#Verify permissions
echo "Permissions after chmod:"
ls -l ${PREFIX}/share/tamper/src/
