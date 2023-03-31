#! /usr/bin/env python3
import tensorflow as tf

from tensorflow.keras.models import Model
from tensorflow.keras.layers import (Conv1D, LSTM, Dense, Bidirectional, Dropout, Reshape,
                                     Activation, Input, BatchNormalization)
from helixer.prediction.HelixerModel import HelixerModel, HelixerSequence


class HybridSequence(HelixerSequence):
    def __init__(self, model, h5_files, mode, batch_size, shuffle):
        super().__init__(model, h5_files, mode, batch_size, shuffle)

    def __getitem__(self, idx):
        X, y, sw, transitions, phases, _, coverage_scores = self._generic_get_item(idx)

        if self.only_predictions:
            return X
        else:
            return X, y, sw


class HybridModel(HelixerModel):
    def __init__(self, cli_args=None):
        super().__init__(cli_args=cli_args)
        self.parser.add_argument('--cnn-layers', type=int, default=1)
        self.parser.add_argument('--lstm-layers', type=int, default=1)
        self.parser.add_argument('--units', type=int, default=32)
        self.parser.add_argument('--filter-depth', type=int, default=32)
        self.parser.add_argument('--kernel-size', type=int, default=26)
        self.parser.add_argument('--pool-size', type=int, default=9)
        self.parser.add_argument('--dropout1', type=float, default=0.0)
        self.parser.add_argument('--dropout2', type=float, default=0.0)
        self.parse_args()

    @staticmethod
    def sequence_cls():
        return HybridSequence

    def model(self):
        values_per_bp = 4
        if self.input_coverage:
            values_per_bp = 6
        main_input = Input(shape=(None, values_per_bp), dtype=self.float_precision,
                           name='main_input')
        x = Conv1D(filters=self.filter_depth,
                   kernel_size=self.kernel_size,
                   padding="same",
                   activation="relu")(main_input)

        # if there are additional CNN layers
        for _ in range(self.cnn_layers - 1):
            x = BatchNormalization()(x)
            x = Conv1D(filters=self.filter_depth,
                       kernel_size=self.kernel_size,
                       padding="same",
                       activation="relu")(x)

        if self.pool_size > 1:
            x = Reshape((-1, self.pool_size * self.filter_depth))(x)
            # x = MaxPooling1D(pool_size=self.pool_size, padding='same')(x)

        if self.dropout1 > 0.0:
            x = Dropout(self.dropout1)(x)

        x = Bidirectional(LSTM(self.units, return_sequences=True))(x)
        for _ in range(self.lstm_layers - 1):
            x = Bidirectional(LSTM(self.units, return_sequences=True))(x)

        # do not use recurrent dropout, but dropout on the output of the LSTM stack
        if self.dropout2 > 0.0:
            x = Dropout(self.dropout2)(x)

        if self.predict_phase:
            x = Dense(self.pool_size * 4 * 2)(x)  # predict twice a many floats
            x_genic, x_phase = tf.split(x, 2, axis=-1)

            x_genic = Reshape((-1, self.pool_size, 4))(x_genic)
            x_genic = Activation('softmax', name='genic')(x_genic)

            x_phase = Reshape((-1, self.pool_size, 4))(x_phase)
            x_phase = Activation('softmax', name='phase')(x_phase)

            outputs = [x_genic, x_phase]
        else:
            x = Dense(self.pool_size * 4)(x)
            x = Reshape((-1, self.pool_size, 4))(x)
            x = Activation('softmax', name='main')(x)
            outputs = [x]

        model = Model(inputs=main_input, outputs=outputs)
        return model

    def compile_model(self, model):
        if self.predict_phase:
            losses = ['categorical_crossentropy', 'categorical_crossentropy']
            loss_weights = [0.8, 0.2]
        else:
            losses = ['categorical_crossentropy']
            loss_weights = [1.0]

        model.compile(optimizer=self.optimizer,
                      loss=losses,
                      loss_weights=loss_weights,
                      sample_weight_mode='temporal')


if __name__ == '__main__':
    model = HybridModel()
    model.run()
