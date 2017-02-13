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
        self.q_zero = 128


    def write_inst(self,name, in_wire, out_wire):
        # input = a vector of pixels from convolution layer
        # output = vector of same size as input

        inst +="""
  relu #(
    .SIZE("""+str(self.SIZE)+"""),
  )
  """+name+""" (
    .clock(clock),
    .reset(reset),
    .zero(8'd"""+self.q_zero+"""),
    .in(wire8["""+str(in_wire)+"""]),
    .out(wire8["""+str(in_wire)+"""])
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
