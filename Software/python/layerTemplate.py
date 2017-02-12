class LayerTemplate:

    def __init__(self,layer_name):
        self.layer_type = 'layer template'
        self.name = layer_name
        # tensor flow weight variable
        self.tf_var = None # this should be 1 or more parameters for the tensorflow op

        

    def write_inst(self,name, in_wire, out_wire):

           
    def export(self, name, in_wire, out_wire):
        # do any other stuff needed for the layer's
        # verilog implementation
        return write_inst(name,in_wire,out_wire)
        
    def tf_function(self,layer_input):
        # call the tensorflow implementation of the layer
        # for example:
        # return tf.nn.conv2d(layer_input, self.tf_var, strides=[1, 1, 1, 1], padding='VALID')

    def save_trained_layer(self):
        # save any data from tensorflow that will be 
        # needed to export the network to hardware
