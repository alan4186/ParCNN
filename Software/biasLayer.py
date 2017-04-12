import tensorflow as tf
import math
import hw_quantize_ops as hwqo

class BiasLayer:

    def __init__(self, name, size):
        self.layer_type = 'bias'
        self.name = name
        self.size = size
       
        self.b_init_stddev = 0.1
        self.tf_var = tf.Variable(tf.constant(self.b_init_stddev, shape=[size]))
        self.tf_var_q = None # empty until set by quantize function

        self.np_bias = None # should be a numpy array with integers [0,255]
        self.bias_wire_name = self.name +"_bias"
        
        # Parameters
        self.SIZE = size
        


    def write_inst(self,name, in_wire, out_wire):
        # input = a vector of pixels from convolution layer
        # output = vector of same size as input

        inst ="""
  bias #(
    .SIZE("""+str(self.SIZE)+"""),
  )
  """+name+""" (
    .clock(clock),
    .reset(reset),
    .a(wire8["""+str(in_wire)+"""]),
    .b("""+self.bias_wire_name+"""),
    .sum(wire8["""+str(out_wire)+"""])
  );

"""
        return inst
        
    def write_bias_wire(self):
        b_declaration = 'wire [8*SIZE-1:0] '+self.bias_wire_name+';\n'
        b_assign = 'assign '+self.bias_wire_name +' = { '

        # flip the array so the indexes match bit slices
        np_bias_flip = self.np_bias[::-1]

        for i in range(0,np_bias_flip.size):
            b_assign += "8'd"+str(np_bias_flip[i])+', '
        b_assign = b_assign[:-2] + '};'

        return b_declaration + b_assign
   
    def export(self, name, in_wire, out_wire):
        inst = self.write_bias_wire()
        inst += '\n' 
        inst += self.write_inst(name,in_wire,out_wire)
        return inst
       
    def tf_function(self,layer_input, dropout=1):
        # ignore dropout, always add bias value
        return layer_input + self.tf_var

    def save_layer(self):
        self.np_bias = self.tf_var.eval()
        
    def quantize(self,mn,mx,bw):
        self.tf_var_q = hwqo.tf_quantize(self.tf_var,mn,mx,bw)
