#! /usr/bin/env python3
from keras.models import Sequential, Model
from keras.layers import Conv1D, Dense, Flatten, Reshape, Input, BatchNormalization, Activation, MaxPool1D, Dropout, \
    Concatenate
from HelixerModel import HelixerModel, HelixerSequence
from CNNModel import CNNSequence
import random
import numpy as np


class InceptionModel(HelixerModel):
    """Mini-inception like 1D CNN"""
    # This is specifically modelled to replicate the version used by Christopher Guenter in his bachelor's thesis
    # so that we can compare current results (with different data) to previous

    def __init__(self):
        super().__init__()
        self.parser.add_argument('--no_conv_dropout', action="store_true")
        self.parser.add_argument("--depth_multiplier", type=int, default=1)
        self.parser.add_argument("--kernel_med_lrg", type=str, default="9,15",
                                 help="two comma separated integers (kernel sizes for inception blocks)")
        self.parser.add_argument("--kernel_stem", type=str, default="21,1,9",
                                 help="three comma separated integers (kernel sizes for three stem convolutions)")
        self.parse_args()

    @staticmethod
    def _parse_kernel_sizes(ks_string):
        return [[int(x)] for x in ks_string.split(',')]

    def sequence_cls(self):
        return CNNSequence

    def model(self):
        # some non-parameters, that should be
        momentum_vals = [0.7, 0.9, 0.9]
        dropout_vals = [0.5, 0.6, 0.7]
        #kernel_size_vals = [[21], [1], [9]]
        kernel_size_vals = self._parse_kernel_sizes(self.kernel_stem)
        to_pool = [True, False, False]

        input = Input(shape=(self.shape_train[1], 4))

        # pre-inception stem (3X convolution)
        current = input
        filters = 24 * self.depth_multiplier
        for momentum, dropout, kernel_size, pool in zip(momentum_vals,
                                                        dropout_vals,
                                                        kernel_size_vals,
                                                        to_pool):

            conv1 = Conv1D(filters=filters,
                           kernel_size=kernel_size,
                           padding="same",
                           activation=None)(current)

            bn1 = BatchNormalization(axis=-1,
                                     momentum=momentum,
                                     epsilon=0.001,
                                     center=True,
                                     scale=True)(conv1)

            current = Activation(activation="relu")(bn1)

            if pool:
                current = MaxPool1D(pool_size=[2], strides=2)(current)

            if not self.no_conv_dropout:
                current = Dropout(rate=dropout)(current)

        # inception modules
        # more probably should-be-paramenters
        inception_dropout = 0.9
        filter_depth_vars = [48, 96, 96]
        filter_depth_vars = [x * self.depth_multiplier for x in filter_depth_vars]
        current = MaxPool1D(pool_size=[2], strides=2)(current)
        ks_med, ks_large = self._parse_kernel_sizes(self.kernel_med_lrg)
        for filters in filter_depth_vars:
            # 1x
            conv_in1 = Conv1D(filters=filters,
                              kernel_size=[1],
                              padding="same",
                              activation="relu")(current)
            # 9x
            conv_in2 = Conv1D(filters=filters,
                              kernel_size=[1],
                              padding="same",
                              activation="relu")(current)
            conv_in2 = Conv1D(filters=filters,
                              kernel_size=ks_med,
                              padding="same",
                              activation="relu")(conv_in2)

            # 15x
            conv_in3 = Conv1D(filters=filters,
                              kernel_size=[1],
                              padding="same",
                              activation="relu")(current)
            conv_in3 = Conv1D(filters=filters,
                              kernel_size=ks_large,
                              padding="same",
                              activation="relu")(conv_in3)

            if not self.no_conv_dropout:
                conv_in1 = Dropout(rate=inception_dropout)(conv_in1)
                conv_in2 = Dropout(rate=inception_dropout)(conv_in2)
                conv_in3 = Dropout(rate=inception_dropout)(conv_in3)

            current = Concatenate(axis=2)([conv_in1, conv_in2, conv_in3])
        # post-inception FCs
        flattened = Flatten()(current)
        dense = Dense(units=192, activation="relu")(flattened)
        dense_drop = Dropout(rate=0.8)(dense)

        flat_preds = Dense(units=7 * self.shape_train[1], activation="relu")(dense_drop)
        pred_logits = Reshape(target_shape=(self.shape_train[1], 7))(flat_preds)
        # add input & output to actual keras Model
        model = Model(inputs=input, outputs=pred_logits)

        return model

    def compile_model(self, model):
        model.compile(optimizer=self.optimizer,
                      loss='categorical_crossentropy',
                      #sample_weight_mode='temporal',
                      metrics=[
                          'accuracy'])


if __name__ == '__main__':
    model = InceptionModel()
    model.run()
