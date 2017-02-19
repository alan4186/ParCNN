import tensorflow as tf
import math

class BiasLayer:

    def __init__(self, name, size):
        self.layer_type = 'bias'
        self.name = name
        self.size = size
       
        self.b_init_stddev = 0.1
        self.tf_var = tf.Variable(tf.constant(self.b_init_stddev, shape=[size]))
        
        # Parameters
        self.SIZE = size
        


    def write_inst(self,name, in_wire, out_wire):
        # input = a vector of pixels from convolution layer
        # output = vector of same size as input

        inst +="""
  bias #(
    .SIZE("""+str(self.SIZE)+"""),
  )
  """+name+""" (
    .clock(clock),
    .reset(reset),
    .a(wire8["""+str(in_wire)+"""]),
    .b("""+self.bias_wire+"""),
    .sum(wire8["""+str(out_wire)+"""])
  );

"""
        return inst
        
    def export(self, name, in_wire, out_wire):
        #TODO convert np_bias to a verilog string
        self.bias_wire = ''
        #TODO write bias wire, use same method as kernels wire
        return write_inst(name,in_wire,out_wire)
       
    def tf_function(self,layer_input):
        return layer_input + self.tf_var

    def save_trained_layer(self):
        np_bias = self.tf_var.eval()
        
