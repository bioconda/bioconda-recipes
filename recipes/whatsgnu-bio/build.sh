#!/usr/bin/env bash

mkdir -p "${PREFIX}/bin" "${PREFIX}/test_data" "${PREFIX}/example_reports"
chmod +x bin/*
cp bin/* "${PREFIX}/bin/"
cp test_data/* "${PREFIX}/test_data/"
cp example_reports/* "${PREFIX}/example_reports/"

WhatsGNU_get_GenBank_genomes.py -h
WhatsGNU_database_customizer.py -h
WhatsGNU_main.py -h
WhatsGNU_main.py -v
WhatsGNU_plotter.py -h
