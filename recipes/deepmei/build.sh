mkdir -p $PREFIX/bin
ls $PREFIX/bin/
cp -r * $PREFIX/bin/
chmod +x $PREFIX/bin/*
cd $PREFIX/bin/
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
mv ./variables.data-00000-of-00001aa $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.data-00000-of-00001ab $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.data-00000-of-00001ac $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.data-00000-of-00001ad $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.data-00000-of-00001ae $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
mv ./variables.data-00000-of-00001af $PREFIX/bin/DeepMEI_model/weights/val_best_model/variables
echo "check start"
ls -al ./*
echo "check end"
