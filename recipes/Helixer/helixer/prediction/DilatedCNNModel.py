#! /usr/bin/env python3
import random
import numpy as np
import tensorflow as tf

from tensorflow.keras import backend as K
from tensorflow.keras.models import Sequential, Model, load_model
from tensorflow.keras.layers import Conv1D, Dense, Flatten, Dropout, Input
from keras_layer_normalization import LayerNormalization
from tensorflow.keras.losses import categorical_crossentropy
from HelixerModel import HelixerModel, HelixerSequence

class DilatedCNNSequence(HelixerSequence):
    def __getitem__(self, idx):
        X, y, sw, _, _, _ = self._get_batch_data(idx)

        if self.class_weights is not None:
            cls_arrays = [y[:, :, col] == 1 for col in range(4)]  # whether a class is present
            cls_arrays = np.stack(cls_arrays, axis=2).astype(np.int8)
            # add class weights to applicable timesteps
            cw_arrays = np.multiply(cls_arrays, np.tile(self.class_weights, y.shape[:2] + (1,)))
            cw = np.sum(cw_arrays, axis=-1)
            # multiply with previous sample weights
            sw = np.multiply(sw, cw)

        # add the sample weights as extra input so they can be used in the custom loss function
        return [X, sw], y

class DilatedCNNModel(HelixerModel):

    def __init__(self):
        super().__init__()
        self.parser.add_argument('--kernel-size', type=int, default=7)
        self.parser.add_argument('--filter-depth', type=int, default=64)
        self.parser.add_argument('--double-filter-every', type=int, default=2)
        self.parser.add_argument('--dilation-multiplier', type=int, default=3)
        self.parser.add_argument('--dilation-max', type=int, default=100)
        self.parser.add_argument('--n-conv-layers', type=int, default=2)
        self.parser.add_argument('--n-hidden-layers', type=int, default=1)
        self.parser.add_argument('--hidden-layer-size', type=int, default=128)
        self.parser.add_argument('--dropout', type=float, default=0.1)
        self.parse_args()

        assert self.n_conv_layers > 1

    def sequence_cls(self):
        return DilatedCNNSequence

    def custom_loss(self, sample_weights):
        def loss(y_true, y_pred):
            # calculation based on
            # https://github.com/keras-team/keras/blob/fb7f49ef5b07f2ceee1d2d6c45f273df6672734c/keras/backend/tensorflow_backend.py#L3570
            axis = -1
            y_pred /= tf.reduce_sum(input_tensor=y_pred, axis=axis, keepdims=True)
            # manual computation of crossentropy
            _epsilon = tf.convert_to_tensor(value=K.epsilon(), dtype=y_pred.dtype.base_dtype)
            y_pred = tf.clip_by_value(y_pred, _epsilon, 1. - _epsilon)
            y_true = tf.cast(y_true, dtype=tf.float32)
            neg_log_likelihood = - tf.reduce_sum(input_tensor=y_true * tf.math.log(y_pred), axis=axis)
            # mask by sample weights
            masked = tf.multiply(neg_log_likelihood, sample_weights)
            return masked
        return loss

    def model(self):
        input_X = Input(shape=(self.shape_train[1], 4))
        input_sw = Input(shape=(self.shape_train[1],))

        x = Conv1D(filters=self.filter_depth,
                   kernel_size=self.kernel_size,
                   input_shape=(self.shape_train[1], 4),
                   padding="same",
                   activation="relu")(input_X)

        dilation = 1
        for l in range(self.n_conv_layers - 1):
            if dilation * self.dilation_multiplier <= self.dilation_max:
                dilation *= self.dilation_multiplier
            if (l + 1) % self.double_filter_every == 0:
                self.filter_depth *= 2
            x = Conv1D(filters=self.filter_depth,
                       kernel_size=self.kernel_size,
                       dilation_rate=dilation,
                       padding="same",
                       activation="relu")(x)

        for _ in range(self.n_hidden_layers):
            x = Dropout(self.dropout)(x)
            x = Dense(self.hidden_layer_size, activation="relu")(x)

        x = Dropout(self.dropout)(x)
        out = Dense(4, activation="softmax")(x)
        model = Model(inputs=[input_X, input_sw], outputs=out)
        return model

    def compile_model(self, model):
        model.compile(optimizer=self.optimizer,
                      # loss='categorical_crossentropy',
                      loss=self.custom_loss(model.inputs[1]),
                      metrics=['accuracy'])


    def _load_helixer_model(self):
        if self.resume_training:
            # todo, fix properly
            print('ERROR: cannot currently use custom_loss to resume training...')
            model = load_model(self.load_model_path, custom_objects = {
            'LayerNormalization': LayerNormalization,
            })
        else:
            model = load_model(self.load_model_path, custom_objects = {
                'LayerNormalization': LayerNormalization,
                'loss': categorical_crossentropy,  # todo, fix to use custom loss
                # the above is OK for predictions / eval that doesn't use loss...
            })
        return model

if __name__ == '__main__':
    model = DilatedCNNModel()
    model.run()
