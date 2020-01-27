#!/bin/bash

cp src/*.py ${PREFIX}/bin/

# Making use of older models possible
sed -i 's/model.load_state_dict(torch.load(model_name, map_location=device))/model.load_state_dict(torch.load(model_name, map_location=device),strict=False)/g' ${PREFIX}/bin/DeepRibo.py
# Removing sys.exit() program call to allow use in workflow managers
sed -i 's/sys.exit(ParseArgs())/ParseArgs()/g' ${PREFIX}/bin/DeepRibo.py

chmod 755 ${PREFIX}/bin/*
