from collections import OrderedDict
from Tkinter import *
import math

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
                    + str(ky_size) + ', Input Y size: ' + str(iy_size))
       
        # check that the z dimension of the kernel and input match
        if kz_size != iz_size:
            raise ValueError("The kernel and input must have " +
                    "the same Z dimension. kz_size = " +
                    str(kz_size)+", iz_size = " + str(iz_size)

        # check that the requantize range is valid
        if rqmin >= rq_max:
            raise ValueError("Invalid requantize range." +
            "rq_min must be less than rq_max. " + 
            "rq_min = "+str(rq_min)+", rq_max = " +str(rq_max)

        #TODO kernel sanity check
        # Check kernel size

        # store kernel data
        # Kernel data should be unsigned decimal strings between [0,255]
        self.kernels = kernels
        self.kernels_wire_name = self.name+"_kernels"

        # compute parameters
        # tree sharing is not implemented yet, each kernel gets its own tree
        self.NUM_TREES = num_kernels 
        self.Z_DEPTH = kz_size
        self.P_SR_DEPTH = kx_size
        self.RAM_SR_DEPTH = ix_size - kx_size
        self.NUM_SR_ROWS = ky_size
        # Round the tree size up to the next power of 2 
        # to keep the tree code simple, extra resources should 
        # be optimized away.
        self.MA_TREE_SIZE = int(2**math.ceil(math.log(8 * kx_size * ky_size,2)))

        self.rq_max = rq_max
        self.rq_min = rq_min
        

    def write_inst(self,name, in_wire, out_wire):
        inst = "wire [31:0] wire_32_"+str(in_wire)+";\n"
        inst +="""
  convolution_25D #(
    .NUM_TREES("""+str(self.NUM_TREES)+"""),
    .Z_DEPTH("""+str(self.Z_DEPTH)+"""),
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

