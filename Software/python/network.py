from collections import OrderedDict
# A class to describe the network that will be implemented in hardware
class Net:

    def __init__(self):
        self.layers = OrderedDict()

    def add_conv(self, name, x_size, y_size, num_kernels):
        
    def add_relu(self):

    def add_max_pool(self):

    def add_dense(self):







class InputLayer:
    
    def __init__(self, x_size, y_size):
        self.x_size = x_size
        self.y_size = y_size
class ConvLayer:

    def __init__(self, kx_size, ky_size, num_kernels, ix_size, iy_size, sharing_factor):
        self.kx_size = x_size
        self.ky_size = y_size
        self.num_kernels = num_kernels
        self.ix_size = ix_size
        self.iy_size = iy_size
        self.sharing_factor = sharing_factor

        # Compute properties for network



class ReluLayer:

    def __init__(self):

class MaxPoolingLayer:

    def __init__(self):

class DenseLayer:

    def __init__(self):
