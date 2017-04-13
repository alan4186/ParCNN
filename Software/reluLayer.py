import tensorflow as tf
import math
import hw_quantize_ops as hwqo

class ReluLayer:

    def __init__(self, name, size, q_max, q_min):
        self.layer_type = 'relu'
        self.name = name
        self.size = size
        self.q_max = q_max
        self.q_min = q_min
        
        self.tf_var = 0.0 # The value of zero relative to the input, will not be 0 for quantized ops
        self.tf_var_q = None # empty until set by quantize function
        
        
        # Parameters
        self.SIZE = size


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
    .zero(8'd"""+str(self.tf_var_q)+"""),
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

    def quantize(self, mn, mx, bw):
        self.tf_var_q = hwqo.tf_quantize(self.tf_var,mn,mx,bw)

    def tf_function_q(self,layer_input):
        return tf.nn.relu(layer_input)


