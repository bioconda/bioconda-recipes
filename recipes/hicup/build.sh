#!/bin/bash
cp -R {hicup_deduplicator,hicup_filter,hicup_module.pm,hicup_truncater,hicup,hicup_digester,hicup_mapper,r_scripts,config_files,Misc} ${PREFIX}/bin
chmod +x {hicup_deduplicator,hicup_filter,hicup_module.pm,hicup_truncater,hicup,hicup_digester,hicup_mapper}
cd ..
rm -rf hicup_v0.5.9