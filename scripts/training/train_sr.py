import os
import sys
import random
import logging
import argparse

import sympy
import numpy as np 
import tensorflow as tf

from utils import *
from copy import deepcopy
from random import randrange
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split

from tensorflow import keras
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
    X_pos = postprocess_data(X_pos, data_points // 2, True)
    logging.debug(f'Removed {prev_len - len(X_pos)} positive samples [either duplicate, or, through data curation]')
    logging.debug(f'Processed {len(X_pos)} positive samples and converted to binary representation!')
    
    prev_len = len(X_neg)
    X_neg = postprocess_data(X_neg, data_points, True)
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
    y = np.reshape(y, (-1, 1))

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
    
    p = np.random.permutation(np.shape(y)[0])
    return X[p], y[p]

# Use SymPy to expand the trained model
def get_expressions(neuralSR):
    # set significant digits for expression display
    significant_digits = 2

    model_dim, operators, num_operators = neuralSR.get_hyperparameters()
    input_dim, num_hidden_layers, output_dim = model_dim
    
    x=[]
    for i in range(input_dim):
        x.append(sympy.Symbol('x{}'.format(i)))
    x_masked = sympy.Matrix([x])
    
    w_input = neuralSR.model.layers[1].get_weights()[1]
    t_input = neuralSR.model.layers[1].get_weights()[0]
    num_input_masks = tf.reduce_sum(tf.cast(tf.where(w_input-t_input>0., 0., 1.),dtype=tf.float64))
    num_input_weights = tf.size(w_input, out_type=tf.float64)
    
    sparsity_input = num_input_masks/num_input_weights
    
    w_input_masked = sympy.Matrix(tf.where(w_input-t_input>0., w_input, 0.))
    x_masked = np.multiply(sympy.Transpose(w_input_masked), x_masked)
    print('Remaining Inputs after pruning: {}\n'.format(str(x_masked).replace('1.0*','')))
    
    num_masks = 0.
    num_weights = 0.
    
    num_unary_masks = 0.
    num_binary_masks = 0.
    num_unary = 0.
    num_binary = 0.
    
    for i in range(num_hidden_layers+1):
        w = neuralSR.model.layers[i+2].get_weights()[0]
        b = neuralSR.model.layers[i+2].get_weights()[1]
        w_t = neuralSR.model.layers[i+2].get_weights()[2]
        b_t = neuralSR.model.layers[i+2].get_weights()[3]
        
        num_masks += tf.reduce_sum(tf.cast(tf.where(tf.abs(w) - w_t > 0., 0., 1.),dtype=tf.float64))
        num_masks += tf.reduce_sum(tf.cast(tf.where(tf.abs(b) - b_t > 0., 0., 1.),dtype=tf.float64))
        num_weights += tf.size(w, out_type=tf.float64)
        num_weights += tf.size(b, out_type=tf.float64)
        
        w_masked = sympy.Matrix(tf.where(tf.abs(w) - w_t > 0., w, 0.))
        b_masked = sympy.Transpose(sympy.Matrix(tf.where(tf.abs(b) - b_t > 0., b, 0.)))
        
        x_masked = (x_masked * w_masked + b_masked).evalf(significant_digits)
        if i < num_hidden_layers:
            unary = neuralSR.model.layers[i+2].get_weights()[6]
            unary_t = neuralSR.model.layers[i+2].get_weights()[4]
            binary = neuralSR.model.layers[i+2].get_weights()[7]
            binary_t = neuralSR.model.layers[i+2].get_weights()[5]
            num_unary_masks += tf.reduce_sum(tf.cast(tf.where(unary - unary_t > 0., 0., 1.),dtype=tf.float64))
            num_binary_masks += tf.reduce_sum(tf.cast(tf.where(binary - binary_t > 0., 0., 1.),dtype=tf.float64))
            num_unary += tf.size(unary, out_type=tf.float64)
            num_binary += tf.size(binary, out_type=tf.float64)
        elif i == num_hidden_layers:
            num_operators.append([output_dim, 0])
            operators.append([['identity'], [None]])
            
        y_masked = sympy.zeros(1, num_operators[i][0] + num_operators[i][1])
        
        unary_mask = sympy.Matrix(tf.where(unary - unary_t > 0., 1., 0.))
        binary_mask = sympy.Matrix(tf.where(binary - binary_t > 0., 1., 0.))
        for j in range(num_operators[i][0]):
            idx = np.mod(j, len(operators[i][0]))
            if i < num_hidden_layers:
                y_masked[0,j] = (unary_mask[j] * math_operation('sympy',operators[i][0][idx],x_masked[0,j]) +
                             (1.0 - unary_mask[j]) * math_operation('sympy','identity',x_masked[0,j]))
            elif i == num_hidden_layers:
                y_masked[0,j] = x_masked[0,j]
        for j in range(num_operators[i][1]):
            idx = np.mod(j, len(operators[i][1]))
            y_masked[0,num_operators[i][0]+j] = (binary_mask[j] * math_operation('sympy',operators[i][1][idx],x_masked[0,num_operators[i][0]+2*j],x_masked[0,num_operators[i][0]+2*j+1]) +
                                              (1.0 - binary_mask[j]) * math_operation('sympy','+',x_masked[0,num_operators[i][0]+2*j],x_masked[0,num_operators[i][0]+2*j+1]))
        x_masked = y_masked.evalf(significant_digits)
    
    sparsity_model = num_masks/num_weights
    sparsity_unary = num_unary_masks/num_unary
    sparsity_binary = num_binary_masks/num_binary
    
    complexity = []
    for j in range(len(x_masked)):
        c = 0
        for _ in sympy.preorder_traversal(x_masked[j]):
            c += 1
        complexity.append(c)
    
    return x_masked, complexity, sparsity_input, sparsity_model, sparsity_unary, sparsity_binary
  
if __name__ == '__main__':
    DATA_PATH = 'data'
    DATA_POINTS = 400000
    logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

    parser = argparse.ArgumentParser()  
    parser.add_argument('--trial', type=str, required=False, default=0)  
    args = parser.parse_args()
    
    pos_dir = 'bin'
    neg_dirs = ['csv', 'jpeg', 'docx', 'pdf', 'rtf', 'sql', 'txt', 'xlsx', 'pptx']
    id = f'{pos_dir}-points-{DATA_POINTS}-trial-{args.trial}'

    X, y = load_data(DATA_PATH, pos_dir, neg_dirs, data_points=DATA_POINTS)
    X_train_val, X_test, y_train_val, y_test = train_test_split(X, y, test_size=0.2, shuffle=True)
    np.save(f'data/X_{id}_train_val.npy', X_train_val)
    np.save(f'data/X_{id}_test.npy', X_test)
    np.save(f'data/y_{id}_train_val.npy', y_train_val)
    np.save(f'data/y_{id}_test.npy', y_test)

    y_train_val = np.reshape(y_train_val, (-1, 1))
    num_hidden = 1
    input_dim  = X_train_val.shape[1]
    output_dim = y_train_val.shape[1]
    model_dim = [input_dim, num_hidden, output_dim]
    operators = [
        [['sin', 'exp'], ['+']],
    ]
    num_operators = [
        [10, 5],
    ]
    model = create_sr_model(
            model_dim=model_dim,
            operators=operators,
            num_operators=num_operators
    )
    model[0].summary()

    logging.debug('Startng to train network')
    logging.debug(f'Using {np.shape(X_train_val)[0]} training/validation data points')
    logging.debug(f'From those, {np.count_nonzero(y_train_val)} are negatives')
    nsr = neuralSR(
        model,
        alpha_sparsity_input=0.8,
        alpha_sparsity_model=0.99,
        alpha_sparsity_unary=0.8,
        alpha_sparsity_binary=0.9
    )
    reduce_lr = ReduceLROnPlateau(monitor='regression_loss', factor=0.1, patience=3, min_delta=1e-2, min_lr=1e-7)
    early_stopping = EarlyStopping(monitor='regression_loss', patience=7, min_delta=1e-2)
    nsr.compile(optimizer=keras.optimizers.Adam(learning_rate=5e-3))
    nsr.fit(X_train_val, y_train_val, epochs=25, batch_size=32, verbose=True, callbacks=[reduce_lr, early_stopping])
    nsr.model.save_weights(f'model_{id}.h5')

    y_test = np.reshape(y_test, (-1, 1))
    pred = np.rint(nsr.model.predict(X_test))
    accuracy = accuracy_score(y_test, pred)
    print(f'Distinguishing {pos_dir} from {neg_dirs} with {round(accuracy * 100, 2)} accuracy on {X_test.shape[0]} test samples with {np.count_nonzero(y_test)} positives')

    expressions_masked, complexity, sparsity_input, sparsity_model, sparsity_unary, sparsity_binary = get_expressions(nsr)
    print('Unroll network into symbolic expressions (input sparsity = {0:.3f}; model sparsity = {1:.3f}; unary sparsity = {2:.3f}; binary sparsity = {2:.3f})\n--------------'.format(sparsity_input, sparsity_model, sparsity_unary, sparsity_binary))
    print('Mean complexity = {0:.1f}\n--------------'.format(np.mean(complexity)))
    for i in range(expressions_masked.shape[1]):
        print('expr_{0} (complexity = {1}):\n\n{2}\n-------------------------------------'.format(i,complexity[i],expressions_masked[i]))
