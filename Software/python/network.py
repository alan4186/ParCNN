from collections import OrderedDict
from Tkinter import *
import math

# A class to describe the network that will be implemented in hardware
class Net(object):

    def __init__(self):
        self.layers = OrderedDict()

    def add_conv(self, name, kx_size, ky_size, num_kernels, ix_size, iy_size, sharing_factor, rq_max, rq_min, kernels):
        self.layers[name] = ConvLayer(name,kx_size,ky_size,num_kernels,ix_size,iy_size,sharing_factor, rq_max, rq_min, kernels)

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

class ConvLayer:

    def __init__(self, name, kx_size, ky_size, kz_size, num_kernels, ix_size, iy_size, iz_size, sharing_factor, rq_max, rq_min, kernels):
        self.layer_type = 'conv'
        self.name = name
        # make sure the kernel size is at least 1 
        # pixel smaller than the input in the x dimension and 
        # the same size as the input in the y dimension
        if ix_size-kx_size < 1:
            raise ValueError('The kernel X dimension must' 
                    + 'be at least 1 less than the input X'
                    + 'dimension. Kernel X size: '
                    + str(kx_size) + ', Input X size: ' +str(ix_size))

        if iy_size-ky_size < 0:
            raise ValueError('The kernel Y dimension must' 
                    + 'be less than or equal to the input Y'
                    +  'dimension. Kernel Y size: '
                    + str(ky_size) + ', Input Y size: ' +str(iy_size))
        
        # store kernel data
        # Kernel data should be unsigned decimal strings between [0,255]
        self.kernels = kernels
        self.kernels_wire_name = self.name+"_kernels"

        # compute parameters
        # tree sharing is not implemented yet, each kernel gets its own tree
        self.NUM_TREES = num_kernels 
        self.P_SR_DEPTH = kx_size
        self.RAM_SR_DEPTH = ix_size - kx_size
        self.NUM_SR_ROWS = ky_size * kz_size
        # Round the tree size up to the next power of 2 
        # to keep the tree code simple, extra resources should 
        # be optimized away.
        self.MA_TREE_SIZE = int(2**math.ceil(math.log(8 * kx_size * ky_size,2)))

        self.rq_max = rq_max
        self.rq_min = rq_min
        

    def write_inst(self,name, in_wire, out_wire):
        inst = "wire [31:0] wire_32_"+str(in_wire)+";\n"
        inst +="""
  convolution #(
    .NUM_TREES("""+str(self.NUM_TREES)+"""),
    .P_SR_DEPTH("""+str(self.P_SR_DEPTH)+"""), 
    .RAM_SR_DEPTH("""+str(self.RAM_SR_DEPTH)+"""),
    .NUM_SR_ROWS("""+str(self.NUM_SR_ROWS)+"""),
    .MA_TREE_SIZE("""+str(self.MA_TREE_SIZE)+""")
  )
  """+name+""" (
    .clock(clock),
    .reset(reset),
    .pixel_in(wire8["""+str(in_wire)+"""]),
    .kernel("""+self.kernels_wire_name+"""),
    .pixel_out(wire32_"""+str(in_wire)+""")
  );

  requantize rq_inst_"""+str(in_wire)+""" (
    .clock(clock),
    .reset(reset),
    .pixel_in(wire32_"""+str(in_wire)+"""),
    .max_val("""+str(self.rq_max)+"""),
    .min_val("""+str(self.rq_min)+"""),
    .pixel_out(wire8["""+str(out_wire)+"""])
  );
"""
        return inst

    def write_kernel_file(self):
        #TODO write kernel wire declaration in seperate file
        "under construction"

class ReluLayer:

    def __init__(self):
        print 'under construction'

class MaxPoolingLayer:

    def __init__(self):
        print 'under construction'

