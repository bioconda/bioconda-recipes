#!/usr/bin/env bash

python3 setup.py install --single-version-externally-managed --record=record.txt

mkdir -p $PREFIX/bin

chmod u+x $SP_DIR/biobb_ml/regression/linear_regression.py
cp $SP_DIR/biobb_ml/regression/linear_regression.py $PREFIX/bin/linear_regression

chmod u+x $SP_DIR/biobb_ml/regression/polynomial_regression.py
cp $SP_DIR/biobb_ml/regression/polynomial_regression.py $PREFIX/bin/polynomial_regression

chmod u+x $SP_DIR/biobb_ml/regression/random_forest_regressor.py
cp $SP_DIR/biobb_ml/regression/random_forest_regressor.py $PREFIX/bin/random_forest_regressor

chmod u+x $SP_DIR/biobb_ml/regression/regression_predict.py
cp $SP_DIR/biobb_ml/regression/regression_predict.py $PREFIX/bin/regression_predict

chmod u+x $SP_DIR/biobb_ml/classification/decision_tree.py
cp $SP_DIR/biobb_ml/classification/decision_tree.py $PREFIX/bin/decision_tree

chmod u+x $SP_DIR/biobb_ml/classification/k_neighbors_coefficient.py
cp $SP_DIR/biobb_ml/classification/k_neighbors_coefficient.py $PREFIX/bin/k_neighbors_coefficient

chmod u+x $SP_DIR/biobb_ml/classification/k_neighbors.py
cp $SP_DIR/biobb_ml/classification/k_neighbors.py $PREFIX/bin/k_neighbors

chmod u+x $SP_DIR/biobb_ml/classification/logistic_regression.py
cp $SP_DIR/biobb_ml/classification/logistic_regression.py $PREFIX/bin/logistic_regression

chmod u+x $SP_DIR/biobb_ml/classification/random_forest_classifier.py
cp $SP_DIR/biobb_ml/classification/random_forest_classifier.py $PREFIX/bin/random_forest_classifier

chmod u+x $SP_DIR/biobb_ml/classification/support_vector_machine.py
cp $SP_DIR/biobb_ml/classification/support_vector_machine.py $PREFIX/bin/support_vector_machine

chmod u+x $SP_DIR/biobb_ml/classification/classification_predict.py
cp $SP_DIR/biobb_ml/classification/classification_predict.py $PREFIX/bin/classification_predict

chmod u+x $SP_DIR/biobb_ml/clustering/agglomerative_coefficient.py
cp $SP_DIR/biobb_ml/clustering/agglomerative_coefficient.py $PREFIX/bin/agglomerative_coefficient

chmod u+x $SP_DIR/biobb_ml/clustering/agglomerative_clustering.py
cp $SP_DIR/biobb_ml/clustering/agglomerative_clustering.py $PREFIX/bin/agglomerative_clustering

chmod u+x $SP_DIR/biobb_ml/clustering/dbscan.py
cp $SP_DIR/biobb_ml/clustering/dbscan.py $PREFIX/bin/dbscan

chmod u+x $SP_DIR/biobb_ml/clustering/k_means_coefficient.py
cp $SP_DIR/biobb_ml/clustering/k_means_coefficient.py $PREFIX/bin/k_means_coefficient

chmod u+x $SP_DIR/biobb_ml/clustering/k_means.py
cp $SP_DIR/biobb_ml/clustering/k_means.py $PREFIX/bin/k_means

chmod u+x $SP_DIR/biobb_ml/clustering/spectral_coefficient.py
cp $SP_DIR/biobb_ml/clustering/spectral_coefficient.py $PREFIX/bin/spectral_coefficient

chmod u+x $SP_DIR/biobb_ml/clustering/spectral_clustering.py
cp $SP_DIR/biobb_ml/clustering/spectral_clustering.py $PREFIX/bin/spectral_clustering

chmod u+x $SP_DIR/biobb_ml/clustering/clustering_predict.py
cp $SP_DIR/biobb_ml/clustering/clustering_predict.py $PREFIX/bin/clustering_predict

chmod u+x $SP_DIR/biobb_ml/utils/correlation_matrix.py
cp $SP_DIR/biobb_ml/utils/correlation_matrix.py $PREFIX/bin/correlation_matrix

chmod u+x $SP_DIR/biobb_ml/utils/dendrogram.py
cp $SP_DIR/biobb_ml/utils/dendrogram.py $PREFIX/bin/dendrogram

chmod u+x $SP_DIR/biobb_ml/utils/dummy_variables.py
cp $SP_DIR/biobb_ml/utils/dummy_variables.py $PREFIX/bin/dummy_variables

chmod u+x $SP_DIR/biobb_ml/utils/map_variables.py
cp $SP_DIR/biobb_ml/utils/map_variables.py $PREFIX/bin/map_variables

chmod u+x $SP_DIR/biobb_ml/utils/pairwise_comparison.py
cp $SP_DIR/biobb_ml/utils/pairwise_comparison.py $PREFIX/bin/pairwise_comparison

chmod u+x $SP_DIR/biobb_ml/neural_networks/autoencoder_neural_network.py
cp $SP_DIR/biobb_ml/neural_networks/autoencoder_neural_network.py $PREFIX/bin/autoencoder_neural_network

chmod u+x $SP_DIR/biobb_ml/neural_networks/classification_neural_network.py
cp $SP_DIR/biobb_ml/neural_networks/classification_neural_network.py $PREFIX/bin/classification_neural_network

chmod u+x $SP_DIR/biobb_ml/neural_networks/recurrent_neural_network.py
cp $SP_DIR/biobb_ml/neural_networks/recurrent_neural_network.py $PREFIX/bin/recurrent_neural_network

chmod u+x $SP_DIR/biobb_ml/neural_networks/regression_neural_network.py
cp $SP_DIR/biobb_ml/neural_networks/regression_neural_network.py $PREFIX/bin/regression_neural_network

chmod u+x $SP_DIR/biobb_ml/neural_networks/neural_network_decode.py
cp $SP_DIR/biobb_ml/neural_networks/neural_network_decode.py $PREFIX/bin/neural_network_decode

chmod u+x $SP_DIR/biobb_ml/neural_networks/neural_network_predict.py
cp $SP_DIR/biobb_ml/neural_networks/neural_network_predict.py $PREFIX/bin/neural_network_predict

chmod u+x $SP_DIR/biobb_ml/dimensionality_reduction/pls_components.py
cp $SP_DIR/biobb_ml/dimensionality_reduction/pls_components.py $PREFIX/bin/pls_components

chmod u+x $SP_DIR/biobb_ml/dimensionality_reduction/pls_regression.py
cp $SP_DIR/biobb_ml/dimensionality_reduction/pls_regression.py $PREFIX/bin/pls_regression

chmod u+x $SP_DIR/biobb_ml/dimensionality_reduction/principal_component.py
cp $SP_DIR/biobb_ml/dimensionality_reduction/principal_component.py $PREFIX/bin/principal_component