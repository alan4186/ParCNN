import tensorflow as tf
import math

class BiasLayer:

    def __init__(self, name, size):
        self.layer_type = 'bias'
        self.name = name
        self.size = size
       
        self.b_init_stddev = 0.1
        self.tf_var = tf.Variable(tf.constant(self.b_init_stddev, shape=[size]))

        self.np_bias = None # should be a numpy array with integers [0,255]
        
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
        inst = write_bias_wire()
        inst += '\n' 
        inst += write_inst(name,in_wire,out_wire)
        return inst
       
    def tf_function(self,layer_input):
        return layer_input + self.tf_var

    def save_trained_layer(self):
        np_bias = self.tf_var.eval()
        
