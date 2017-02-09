from collections import OrderedDict
from Tkinter import *
import math

from convLayer import ConvLayer
# A class to describe the network that will be implemented in hardware
class Net(object):

    def __init__(self):
        self.layers = OrderedDict()

    def add_conv(self, name, kx_size, ky_size, kz_size, num_kernels, ix_size, iy_size, iz_size, sharing_factor, rq_max, rq_min, kernels):
        self.layers[name] = ConvLayer(name,kx_size,ky_size,kz_size,num_kernels,ix_size,iy_size,iz_size,sharing_factor, rq_max, rq_min, kernels)

    def add_relu(self):
        print 'under construction'

    def add_max_pool(self):
        print 'under construction'

    def export(self):
        print 'under construction'

    def write_cnn_module(self):
        cnn_module = ''
        port_list = \
"""module cnn (
input clock,
input reset,
input [7:0] pixel_in,
output [7:0] pixel_out
);
"""
        cnn_module = cnn_module + port_list

        # create wire declarations
        num_wires = len(self.layers.keys()) + 2
        wire8 = "wire [7:0] wire8 ["+str(num_wires)+":0];\n\n"
        
        cnn_module = cnn_module + wire8 
        
        wire_index = 0
        # instantiate layer modules
        for pair in self.layers.items():
            v = pair[1]
            inst = v.write_inst(pair[0], wire_index, wire_index+1)
            wire_index += 1 
            cnn_module += inst

        cnn_module +="\nassign pixel_out = wire8["+str(wire_index)+"];\n\n"

        cnn_module += "endmodule"
        return cnn_module

class InputLayer:
    
    def __init__(self, x_size, y_size):
        self.x_size = x_size
        self.y_size = y_size

class ReluLayer:

    def __init__(self):
        print 'under construction'

class MaxPoolingLayer:

    def __init__(self):
        print 'under construction'

