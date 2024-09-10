import argparse
import numpy as np
from qkeras.utils import _add_supported_quantized_objects 
from utils import load_file, postprocess_data, DenseIntrusionModel

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file-path')
    parser.add_argument('model-weights')
    parser.add_argument('--clock', type=int, default=4)
    
    file_to_evaluate = vars(parser.parse_args())['file-path']
    model_weights = vars(parser.parse_args())['model-weights']
    
    co = {}
    _add_supported_quantized_objects(co)
    co['DenseIntrusionModel'] = DenseIntrusionModel

    model = DenseIntrusionModel(precision=3)
    model.load_weights(model_weights)

    X = load_file(file_to_evaluate, 512)
    X = postprocess_data(X, data_points = -1, remove_duplicates=False)    
    X = np.array(X, dtype=np.bool_)
    y = np.rint(model.predict(X)).flatten().astype('int')
    print('Locations of 512-bit vectors marked as "executable/unsafe": ', np.where(y == 1))
    print('Locations of 512-bit vectors marked as "safe": ', np.where(y == 0))
