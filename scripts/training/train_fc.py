import os
import sys
import random
import logging
import argparse
import numpy as np 

from utils import *
from copy import deepcopy
from random import randrange
from sklearn.model_selection import train_test_split
from tensorflow.keras.callbacks import ReduceLROnPlateau, EarlyStopping

def load_data(data_path: str, pos_dir: str, neg_dirs: list, data_points: int = -1, word_length: int = 512) -> tuple:    
    # Load data
    logging.debug(f'Loading positive files, with extension: {pos_dir}')
    X_pos = []
    pos_files = os.listdir(f'{data_path}/{pos_dir}')
    for file_name in pos_files:
        X_pos += load_file(f'{data_path}/{pos_dir}/{file_name}', word_length)

    logging.debug(f'Loading negative samples, with identifiers={neg_dirs}')
    X_neg = []
    for neg_id in neg_dirs:
        neg_files = os.listdir(f'{data_path}/{neg_id}')
        for file_name in neg_files:
            X_neg += load_file(f'{data_path}/{neg_id}/{file_name}', word_length)           

    # Post-process
    prev_len = len(X_pos)    
    X_pos = postprocess_data(X_pos, data_points // 2)
    logging.debug(f'Removed {prev_len - len(X_pos)} positive samples [either duplicate, or, through data curation]')
    logging.debug(f'Processed {len(X_pos)} positive samples and converted to binary representation!')
    
    prev_len = len(X_neg)
    X_neg = postprocess_data(X_neg, data_points)
    logging.debug(f'Removed {prev_len - len(X_neg)} negative samples [either duplicate, or, through data curation]')
    logging.debug(f'Processed {len(X_neg)} negative samples and converted to binary representation!')

    # Add embedded data points
    logging.debug(f'Including artificial, embedded data points')
    for _ in range(data_points // 2):
        length = random.randint(1, word_length // 64 - 1)                     # Generate between 1 and 7 binary instructions
        position = random.randint(0, word_length // 64 - length)              # From the position (and at) 0, 8 - length
        x = deepcopy(random.choice(X_neg))                                    # Select random from the negative samples
        # Select random element from the binaries and add a subset of it to the negative
        x[64 * position : 64 * (position + length)] = random.choice(X_pos)[64 * position : 64 * (position + length)] 
        X_pos.append(x)
    
    # Convert to NumPy
    X = np.array(X_pos + X_neg, dtype=np.bool_)
    y = np.array([1] * len(X_pos) + [0] * len(X_neg), dtype=np.bool_)

    # Sanity checks
    logging.debug('Checking no data is lost...')
    assert(np.shape(X)[0] == np.shape(y)[0])
    assert(np.count_nonzero(y) == len(X_pos))
    assert(np.shape(X)[0] == len(X_pos) + len(X_neg))
    assert(np.all(y[0:DATA_POINTS] == 1))
    assert(np.all(y[DATA_POINTS : 2 * DATA_POINTS] == 0))
    logging.debug('Data loaded and converted to NumPy arrays!')
    logging.debug(f'[SANITY CHECK] Data shape is: {X.shape}')
    random_position = randrange(X.shape[0])
    logging.debug(f'[SANITY CHECK] A random data point with label: {y[random_position]} is {X[random_position]}')
    
    # VERIFIED - It's union shuffling
    p = np.random.permutation(np.shape(y)[0])
    return X[p], y[p]

if __name__ == '__main__':
    logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
    DATA_PATH = 'data'
    DATA_POINTS = 400000

    parser = argparse.ArgumentParser()  
    parser.add_argument('--trial', type=str, required=False, default=0)  
    parser.add_argument('--precision', type=int, required=False, default=3)  
    args = parser.parse_args()
    
    pos_dir = 'bin'
    neg_dirs = ['csv', 'jpeg', 'docx', 'pdf', 'rtf', 'sql', 'txt', 'xlsx', 'pptx']
    precision = args.precision
    use_bias = False if precision == 3 or precision == 1 else True
    id = f'{pos_dir}-points-{DATA_POINTS}-trial-{args.trial}'

    X, y = load_data(DATA_PATH, pos_dir, neg_dirs, data_points=DATA_POINTS)
    X_train_val, X_test, y_train_val, y_test = train_test_split(X, y, test_size=0.2, shuffle=True)
    np.save(f'data/X_{id}_train_val.npy', X_train_val)
    np.save(f'data/X_{id}_test.npy', X_test)
    np.save(f'data/y_{id}_train_val.npy', y_train_val)
    np.save(f'data/y_{id}_test.npy', y_test)

    model = DenseIntrusionModel(precision=precision, use_bias=use_bias)
    logging.debug('Startng to train network')
    logging.debug(f'Using {np.shape(X_train_val)[0]} training/validation data points')
    logging.debug(f'From those, {np.count_nonzero(y_train_val)} are negatives')
    reduce_lr = ReduceLROnPlateau(factor=0.1, patience=2, min_delta=1e-2, min_lr=1e-7)
    early_stopping = EarlyStopping(patience=6, min_delta=1e-2)
    model.fit(X_train_val, y_train_val, epochs=25, batch_size=32, validation_split=0.2, callbacks=[reduce_lr, early_stopping])
    model.save_weights(f'model_{id}_precision_{precision}_usebias_{use_bias}.h5')

    accuracy = model.accuracy(X_test, y_test)
    print(f'Distinguishing {pos_dir} from {neg_dirs} with {round(accuracy * 100, 2)} accuracy on {X_test.shape[0]} test samples with {np.count_nonzero(y_test)} positives')
