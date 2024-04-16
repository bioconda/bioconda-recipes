mkdir -p $PREFIX/bin
ls $PREFIX/bin/
cp -r * $PREFIX/bin/
mkdir -p $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mkdir -p $PREFIX/bin/data_cluster/candidate_locus
mkdir -p $PREFIX/bin/DeepMEI_model/batch_cdgc
mkdir -p $PREFIX/bin/DeepMEI_model/reference
#cd $PREFIX/bin/
curl -o $PREFIX/bin/candidate_locus.tar.gz  https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/candidate_locus.tar.gz
tar -zxvf  $PREFIX/bin/candidate_locus.tar.gz
mv ./candidate_locus/* $PREFIX/bin/data_cluster/candidate_locus
curl -o $PREFIX/bin/batch_cdgc.tar.gz https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/batch_cdgc.tar.gz
tar -zxvf  $PREFIX/bin/batch_cdgc.tar.gz
mv ./batch_cdgc/* $PREFIX/bin/DeepMEI_model/batch_cdgc
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/keras_metadata.pb  https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/keras_metadata.pb
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/saved_model.pb https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/saved_model.pb
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001aa https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001aa
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ab https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ab
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ac https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ac
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ad curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ad
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ae  https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ae
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001af  https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001af
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.index curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.index
curl -o $PREFIX/bin/reference.00 https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.00
curl -o $PREFIX/bin/reference.01 https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.01
curl -o $PREFIX/bin/reference.02 https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.02
curl -o $PREFIX/bin/reference.03 https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.03
curl -o $PREFIX/bin/reference.04 https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.04
curl -o $PREFIX/bin/reference.05 https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.05
cat $PREFIX/bin/reference.0* > $PREFIX/bin/reference.tar.gz
tar -zxvf $PREFIX/bin/reference.tar.gz
mv  ./reference/* $PREFIX/bin/DeepMEI_model/reference
rm -rf $PREFIX/bin/reference.0* $PREFIX/bin/reference.tar.gz 
chmod +x $PREFIX/bin/*
echo "check start"
ls -al ./*
echo "check end"
