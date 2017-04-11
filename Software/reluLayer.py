import tensorflow as tf
import math

class ReluLayer:

    def __init__(self, name, size, q_max, q_min):
        self.layer_type = 'relu'
        self.name = name
        self.size = size
        self.q_max = q_max
        self.q_min = q_min
        
        self.tf_var = None
        
        # Parameters
        self.SIZE = size
        #TODO compute real zero value in 8 bits
        self.q_zero = 128


    def write_inst(self,name, in_wire, out_wire):
        # input = a vector of pixels from convolution layer
        # output = vector of same size as input

        inst ="""
  relu #(
    .SIZE("""+str(self.SIZE)+"""),
  )
  """+name+""" (
    .clock(clock),
    .reset(reset),
    .zero(8'd"""+str(self.q_zero)+"""),
    .in(wire8["""+str(in_wire)+"""]),
    .out(wire8["""+str(out_wire)+"""])
  );

"""
        return inst
        
    def export(self, name, in_wire, out_wire):
        return self.write_inst(name,in_wire,out_wire)
       
    def tf_function(self,layer_input,dropout=1):
        # ignore dropout probability
        return tf.nn.relu(layer_input)

    def save_layer(self):
        # Do nothin, no network parameters to save
        return None
