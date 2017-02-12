import tensorflow as tf
import math

class ReluLayer:

    def __init__(self, name, q_max, q_min):
        self.layer_type = 'relu'
        self.name = name

        self.q_max = q_max
        self.q_min = q_min
        
        self.tf_var = None
        
        # Parameters
        #TODO compute real zero value in 8 bits
        self.Q_ZERO = 128


    def write_inst(self,name, in_wire, out_wire):
        # input = a vector of pixels from convolution layer
        # output = vector of same size as input

        inst +="""
  relu #(
    .Q_ZERO("""+str(self.Q_ZERO)+"""),
  )
  """+name+""" (
    .clock(clock),
    .reset(reset),
    .in(wire8["""+str(in_wire)+"""]),
    .out(wire32_"""+str(in_wire)+""")
  );
"""
        return inst
        
    def export(self, name, in_wire, out_wire):
        return write_inst(name,in_wire,out_wire)
       
    def tf_function(self,layer_input):
        return tf.nn.relu(layer_input)

    def save_trained_layer(self):
        # Do nothin, no network parameters to save
        return None
