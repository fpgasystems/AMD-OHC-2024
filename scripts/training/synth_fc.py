import os
import shutil
import argparse

from utils import DenseIntrusionModel
from qkeras import QDense, QActivation
from tensorflow.keras.layers import Dense
from tensorflow.keras.models import Sequential
from hls4ml.utils import config_from_keras_model
from hls4ml.converters import convert_from_keras_model
from qkeras.utils import _add_supported_quantized_objects 

def build_and_compare(
    keras_model, model_id, part, clock   
):
    # Remove any previous synthesis with the same ID, if found
    synthesis_id = f'roce_{model_id}'.lower()
    synthesis_directory = 'hls-synth/' + synthesis_id
    if os.path.isdir(synthesis_directory):
        shutil.rmtree(synthesis_directory)
    os.makedirs(synthesis_directory)
    
    # hls4ml config --- the precision may need to be tuned, depending on the model
    hls_config = config_from_keras_model(keras_model, granularity='name', default_precision='ap_fixed<16, 8>')     
    hls_config['Model']['Strategy'] = 'Latency'
    hls_config['LayerName']['q_dense_input']['Precision']['result'] = 'ufixed<1, 1>'
    hls_config['LayerName']['dense_sigmoid']['Precision']['result'] = 'ufixed<1, 1>'

    # Convert model to HLS
    hls_model = convert_from_keras_model(
                            keras_model, 
                            hls_config=hls_config,
                            output_dir=synthesis_directory, 
                            backend='Vitis',
                            part=part,
                            clock_period=clock
                        )
    hls_model.compile()
    hls_model.build(reset=True, csim=True, cosim=True, validation=True, export=True, synth=True, vsynth=True)

if __name__ == '__main__':
    #####################
    #   CLI Arguments   #
    #####################
    parser = argparse.ArgumentParser()
    parser.add_argument('project-name')
    parser.add_argument('model-weights')
    parser.add_argument('--clock', type=int, default=4)
    
    project_name = vars(parser.parse_args())['project-name']
    model_weights = vars(parser.parse_args())['model-weights']
    clock = vars(parser.parse_args())['clock']

    ##################
    #  Model & Data  #
    ##################
    co = {}
    _add_supported_quantized_objects(co)
    co['DenseIntrusionModel'] = DenseIntrusionModel

    PRECISION = 3
    USE_BIAS = False
    model = Sequential()
    kernel_quantizer = 'ternary'
    layer_activation = f'quantized_relu({PRECISION})'
    model.add(QDense(32, input_shape=(512, ), kernel_quantizer=kernel_quantizer, use_bias=USE_BIAS))
    model.add(QActivation(layer_activation))
    model.add(QDense(64, kernel_quantizer=kernel_quantizer, use_bias=USE_BIAS))
    model.add(QActivation(layer_activation))
    model.add(QDense(64, kernel_quantizer=kernel_quantizer, use_bias=USE_BIAS))
    model.add(QActivation(layer_activation))
    model.add(Dense(1, activation='sigmoid'))
    model.load_weights(model_weights)

    ###################
    #  HLS Synthesis  #
    ###################
    part = 'xcu55c-fsvh2892-2L-e'
    vivado_pred = build_and_compare(
        model, project_name, part, clock
    )
