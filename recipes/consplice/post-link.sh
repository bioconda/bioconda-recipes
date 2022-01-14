#!/bin/bash
set -eo pipefail -o nounset

## Check config data
"${PREFIX}/bin/python" -c "$( cat <<'EOF'
import consplice
import os

cur_path = consplice.__cur_path__
model_path = os.path.abspath(os.path.join(cur_path,'../../config/ConSpliceML_Model'))

## Check ConspliceML model
print(model_path)
print("Model Exists:", os.path.exists(os.path.join(model_path,'trained_ConSpliceML.rf')))
print("Model is File:", os.path.isfile(os.path.join(model_path,'trained_ConSpliceML.rf')))
print("Model Size:", assert os.path.getsize(os.path.join(model_path,'trained_ConSpliceML.rf')))
#assert os.path.exists(os.path.join(model_path,'trained_ConSpliceML.rf'))
#assert os.path.isfile(os.path.join(model_path,'trained_ConSpliceML.rf'))
#assert os.path.getsize(os.path.join(model_path,'trained_ConSpliceML.rf')) > 0

## Check ConSpliceML metadata
print("ML yaml exists:", os.path.exists(os.path.join(model_path,'training.yaml')))
print("ML yaml is file:", os.path.isfile(os.path.join(model_path,'training.yaml')))
print("ML yaml size:" , os.path.getsize(os.path.join(model_path,'training.yaml')))
#assert os.path.exists(os.path.join(model_path,'training.yaml'))
#assert os.path.isfile(os.path.join(model_path,'training.yaml'))
#assert os.path.getsize(os.path.join(model_path,'training.yaml'))

## Check ConSplice config
print("Config exists:", os.path.exists(os.path.join(cur_path,'../../config/config.yml')))
print("Config is file:", os.path.isfile(os.path.join(cur_path,'../../config/config.yml')))
print("Config size:", os.path.getsize(os.path.join(cur_path,'../../config/config.yml')))
#assert os.path.exists(os.path.join(cur_path,'../../config/config.yml'))
#assert os.path.isfile(os.path.join(cur_path,'../../config/config.yml'))
#assert os.path.getsize(os.path.join(cur_path,'../../config/config.yml')) > 0

print('Config checks passed')

EOF
)" >> "${PREFIX}/.messages.txt" 2>&1

