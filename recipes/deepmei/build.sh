mkdir -p $PREFIX/bin
curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/candidate_locus.zip
curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/batch_cdgc.zip
curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/keras_metadata.pb
curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/saved_model.pb
curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001aa
curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ab
curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ac
curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ad
curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ae
curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001af
curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.index
curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.00
curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.01
curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.02
curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.03
curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.04
curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.05
echo "the present dir is $PWD"
echo `realpath ./variables.data-00000-of-00001aa`
echo `ls -al ./*`
ls $PREFIX/bin/
cp -r * $PREFIX/bin/
mkdir -p $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mkdir -p $PREFIX/bin/data_cluster/candidate_locus
mkdir -p $PREFIX/bin/DeepMEI_model/batch_cdgc
mkdir -p $PREFIX/bin/DeepMEI_model/reference
mv ./variables.data-00000-of-00001aa $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.data-00000-of-00001ab $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.data-00000-of-00001ac $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.data-00000-of-00001ad $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.data-00000-of-00001ae $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.data-00000-of-00001af $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.index $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./keras_metadata.pb $PREFIX/bin/DeepMEI_model/weights/val_best_model/
mv ./saved_model.pb $PREFIX/bin/DeepMEI_model/weights/val_best_model/
unzip ./candidate_locus.zip
mv candidate_locus/* $PREFIX/bin/data_cluster/candidate_locus
unzip ./batch_cdgc.zip
mv batch_cdgc/* $PREFIX/bin/data_cluster/batch_cdgc
cat ./reference.0* > ./reference.tar.gz
tar -zxvf ./reference.tar.gz
mv reference/* $PREFIX/bin/DeepMEI_model/reference
rm -rf ./reference.tar.gz ./reference.0*
chmod +x $PREFIX/bin/*
