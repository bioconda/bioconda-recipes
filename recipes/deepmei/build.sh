mkdir -p $PREFIX/bin
ls $PREFIX/bin/
cp -r * $PREFIX/bin/
mkdir -p $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mkdir -p $PREFIX/bin/data_cluster/candidate_locus
mkdir -p $PREFIX/bin/DeepMEI_model/batch_cdgc
mkdir -p $PREFIX/bin/DeepMEI_model/reference
chmod +x $PREFIX/bin/*
#cd $PREFIX/bin/
#curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/candidate_locus.zip
#curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/batch_cdgc.zip
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/keras_metadata.pb  https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/keras_metadata.pb
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/saved_model.pb https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/saved_model.pb
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001aa https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001aa
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ab https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ab
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ac https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ac
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ad curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ad
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ae  https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ae
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001af  https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001af
curl -o $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables/variables.index curl https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.index
#curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.00
#curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.01
#curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.02
#curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.03
#curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.04
#curl https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.05
echo "the path of variables.data-00000-of-00001aa is `realpath variables.data-00000-of-00001aa`"
echo "check start"
ls -al ./*
echo "check end"
