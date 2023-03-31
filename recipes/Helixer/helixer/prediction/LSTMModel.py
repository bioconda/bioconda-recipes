#! /usr/bin/env python3
import warnings
import tensorflow as tf

warnings.simplefilter(action='ignore', category=FutureWarning)

import os

from keras_layer_normalization import LayerNormalization

from tensorflow.keras.models import Model
from tensorflow.keras.layers import (LSTM, Dense, Bidirectional, Dropout, Reshape, Activation, Input)

from helixer.prediction.HelixerModel import HelixerModel, HelixerSequence


class LSTMSequence(HelixerSequence):
    def __init__(self, model, h5_files, mode, batch_size, shuffle):
        super().__init__(model, h5_files, mode, batch_size, shuffle)

    def __getitem__(self, idx):
        X, y, sw, transitions, phases, _, coverage_scores = self._generic_get_item(idx)

        if self.only_predictions:
            return X
        else:
            return X, y, sw


class LSTMModel(HelixerModel):

    def __init__(self):
        super().__init__()
        self.parser.add_argument('--units', type=int, default=4, help='how many units per LSTM layer')
        self.parser.add_argument('--layers', type=str, default='1', help='how many LSTM layers')
        self.parser.add_argument('--pool-size', type=int, default=9, help='how many bp to predict at once')
        self.parser.add_argument('--dropout', type=float, default=0.0)
        self.parser.add_argument('--layer-normalization', action='store_true')
        self.parse_args()

        if self.layers.isdigit():
            n_layers = int(self.layers)
            self.layers = [self.units] * n_layers
        else:
            self.layers = eval(self.layers)
            assert isinstance(self.layers, list)
        for key in ["save_model_path", "prediction_output_path", "test_data",
                    "load_model_path", "data_dir"]:
            self.__dict__[key] = self.append_pwd(self.__dict__[key])

    @staticmethod
    def append_pwd(path):
        if path is None:
            return path
        elif path.startswith('/'):
            return path
        else:
            pwd = os.getcwd()
            return '{}/{}'.format(pwd, path)

    def sequence_cls(self):
        return LSTMSequence

    def model(self):
        values_per_bp = 4
        if self.input_coverage:
            values_per_bp = 6
        main_input = Input(shape=(None, values_per_bp), dtype=self.float_precision,
                           name='main_input')
        x = Reshape((-1, self.pool_size * values_per_bp))(main_input)
        x = Bidirectional(LSTM(self.layers[0], return_sequences=True))(x)

        # potential next layers
        if len(self.layers) > 1:
            for layer_units in self.layers[1:]:
                if self.dropout > 0.0:
                    x = Dropout(self.dropout)(x)
                if self.layer_normalization:
                    x = LayerNormalization()(x)
                x = Bidirectional(LSTM(layer_units, return_sequences=True))(x)

        if self.dropout > 0.0:
            x = Dropout(self.dropout)(x)

        if self.predict_phase:
            x = Dense(self.pool_size * 4 * 2)(x)  # predict twice a many floats
            x_genic, x_phase = tf.split(x, 2, axis=-1)
            if self.pool_size > 1:
                x_genic = Reshape((-1, self.pool_size, 4))(x_genic)
            x_genic = Activation('softmax', name='genic')(x_genic)

            x_phase = Reshape((-1, self.pool_size, 4))(x_phase)
            x_phase = Activation('softmax', name='phase')(x_phase)

            outputs = [x_genic, x_phase]
        else:
            x = Dense(self.pool_size * 4)(x)
            if self.pool_size > 1:
                x = Reshape((-1, self.pool_size, 4))(x)
            x = Activation('softmax', name='main')(x)
            outputs = [x]

        model = Model(inputs=main_input, outputs=outputs)
        return model

    def compile_model(self, model):
        model.compile(optimizer=self.optimizer,
                      loss='categorical_crossentropy',
                      sample_weight_mode='temporal')


if __name__ == '__main__':
    model = LSTMModel()
    model.run()
