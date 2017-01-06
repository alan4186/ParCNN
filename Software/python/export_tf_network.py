import numpy as np


def export_convolution_layer(W_conv, b_conv):
    if W_conv.shape[2] != 1:
        raise ValueError('The number of input channels is ' + str(W_conv.shape[2]) +'. The number of input channels must equal 1.')
    # write each kerenl to a csv file

    # write the biases to a csv file


def export_dense_layer(W_fc, b_fc):

"""
def export_network(cnn):
    for k,v in cnn.iteritems():
        np.savetxt(k+".csv", v.eval(), delimiter=",")
"""
