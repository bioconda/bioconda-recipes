mkdir -p $PREFIX/bin
ls $PREFIX/bin/
cp -r * $PREFIX/bin/
chmod +x $PREFIX/bin/*
curl -C -O https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/candidate_locus.zip
curl -C -O https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/batch_cdgc.zip
curl -C -O https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/keras_metadata.pb
curl -C -O https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/saved_model.pb
curl -C -O https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001aa
curl -C -O https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ab
curl -C -O https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ac
curl -C -O https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ad
curl -C -O https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001ae
curl -C -O https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.data-00000-of-00001af
curl -C -O https://github.com/xuxif/DeepMEI/raw/main/DeepMEI/DeepMEI_model/weights/val_best_model/variables/variables.index
curl -C -O https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.00
curl -C -O https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.01
curl -C -O https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.02
curl -C -O https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.03
curl -C -O https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.04
curl -C -O https://raw.githubusercontent.com/kanglu123/deepmei/deepmei-v1.6.24/reference.05
echo "the present dir is $PWD"
path=$(dirname `realpath ./variables.data-00000-of-00001aa`)
echo "path is: $path"
echo "check start"
ls -al ./*
echo "check end"
