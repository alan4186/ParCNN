from collections import OrderedDict
# A class to describe the network that will be implemented in hardware
class Net:

    def __init__(self):
        self.layers = OrderedDict()

    def add_conv(self, name, kx_size, ky_size, num_kernels, ix_size, iy_size, sharing_factor):
        self.layers[name] = ConvLayer(kx_size,ky_size,num_kernels,ix_size,iy_size,sharing_factor)

    def add_relu(self):

    def add_max_pool(self):

    def add_dense(self):

    def export():





class InputLayer:
    
    def __init__(self, x_size, y_size):
        self.x_size = x_size
        self.y_size = y_size

class ConvLayer:

    def __init__(self, kx_size, ky_size, num_kernels, ix_size, iy_size, sharing_factor):
        self.layer_type = 'conv'
        # make sure the kernel size is at least 1 
        # pixel smaller than the input in the x dimension and 
        # the same size as the input in the y dimension
        if ix_size-kx_size < 1:
            raise ValueError('The kernel X dimension must' 
                    + 'be at least 1 less than the input X'
                    + 'dimension. Kernel X size: '
                    + str(kx_size)', Input X size: ' +str(ix_size)

        if iy_size-ky_size <0:
            raise ValueError('The kernel Y dimension must' 
                    + 'be less than or equal to the input Y'
                    +  'dimension. Kernel Y size: '
                    + str(ky_size)', Input Y size: ' +str(iy_size))

        # compute parameters
        # tree sharing is not implemented yet, each kernel gets its own tree
        self.NUM_TREES = num_kernels 
        self.P_SR_DEPTH = kx_size
        self.RAM_SR_DEPTH = ix_size - kx_size
        self.NUM_SR_ROWS = ky_size
        self.MA_TREE_SIZE = 8 * kx_size * ky_size
        


class ReluLayer:

    def __init__(self):

class MaxPoolingLayer:

    def __init__(self):

class DenseLayer:

    def __init__(self):
