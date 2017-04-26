import tensorflow as tf
import math
import hw_quantize_ops as hwqo

class BiasLayer:

    """A layer which adds a value to the output of a previous layer.

    The shape of the bias layer is determined at initilaization and should 
    match the number of kernels in a convolutional or dense layer.  This 
    layer can be exported ot a verilog module.

    The parameters of this layer are initialized with to a value of 0.1 
    using a tensorflow variable.  The positive value 0.1 is used to prevent
    relu layers from frequently setting neurons to 0.

    """

    def __init__(self, name, size):
        """Construct a bias layer.

        Args:
            name: A unique string to identify this layer.
            size: An integer.  Should be equal to the number of kernels in 
                the previous layer with kernels.

        Returns:
            A BiasLayer objec.

        Raises:

        Examples:

        """

        self.layer_type = 'bias'
        self.name = name
        self.size = size
       
        self.b_init_val = 0.1
        self.tf_var = tf.Variable(
                tf.constant(self.b_init_val, shape=[size]))

        self.tf_var_q = None # empty until set by quantize function

        self.np_bias = None # should be a numpy array with integers [0,255]
        self.input_q_range = None # empyer until the trained network is quantized    
        self.output_q_range = None # empyer until the trained network is quantized    
        
        self.bias_wire_name = self.name +"_bias"
        # Parameters
        self.SIZE = size
        


    def write_inst(self,name, in_wire, out_wire):
        """Create verilog bias module instantiation.

        Use the parameters in the layer to write a synthesizeable verilog 
        module instantiatoin.

        Args:
            name: A string with the name of the module instantiation.
            in_wire: A string with the name of the verilog wire variable to
                connect to the input port of the layer.
            out_wire: A string with the name of the verilog wire variable to
                connect to the output port of the layer.

        Returns:
            A string with a synthesizeable verilog module instantiation.

        Raises:

        Examples:


        """
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
        """Convert tensor to verilog wire variable.

    
        """
        b_declaration = 'wire [8*SIZE-1:0] '+self.bias_wire_name+';\n'
        b_assign = 'assign '+self.bias_wire_name +' = { '

        # flip the array so the indexes match bit slices
        np_bias_flip = self.np_bias[::-1]

        for i in range(0,np_bias_flip.size):
            b_assign += "8'd"+str(np_bias_flip[i])+', '
        b_assign = b_assign[:-2] + '};'

        return b_declaration + b_assign
   
    def export(self, name, in_wire, out_wire):
        """Convert the bias layer to synthesizeable verilog.

        Convert the tf_var to a verilog wire variable and create an string
        with the module instantiations.

        Args:
            name: A string with the name of the module instantiation.
            in_wire: A string with the name of the verilog wire variable to
                connect to the input port of the layer.
            out_wire: A string with the name of the verilog wire variable to
                connect to the output port of the layer.

        Returns:
            A string with the bias wire variable and module instantiation.

        Raises:

        Examples:
       
        """
        inst = self.write_bias_wire()
        inst += '\n' 
        inst += self.write_inst(name,in_wire,out_wire)
        return inst
       
    def tf_function(self,layer_input, dropout=1):
        """Add the biases to the layer_input.

        The bias tensor is added to the layer_input tnesor. The returned
        tensor has the same shape as layer_input.

        The dropout argument is inclueded to keep all tf_functions
        consistant but is ignored here.

        Args:
            layer_input: A tensor output by the previous layer of the
            network.

        Kwargs:
            dropout: A Useless argument, ignored by this function. Can be
                any value.

        Returns:
            A tensor the same size as layer_input.

        Raises:

        Examples:

        """
        return layer_input + self.tf_var

    def save_layer(self):
        """Save the bias tensor.

        Evaluate the bias tensor and save the resulting numpy matrix in the
        np_bias variable.  This function must be called in a tensorflow 
        session.

        """
        self.np_bias = self.tf_var.eval()
        
    def quantize(self, bw):
        """Quantize the floating point bias values.

        Calls the tf_quantize function from the hw_quantize_ops module and
        saves the output to the tf_var_q variable.  The quantization range
        (mn and mx) should be symetric and the bit width (bw) is generally
        8 bits.

        Args:
            mn: The floating point minimum of the quantization range.
            mx: The floating point maximum of the quantization range.
            bw: The bitwiths of the quantized values. Generally equals 8.
        
        Returns:

        Raises:

        Example:

        """
        mn = tf.multiply(self.input_q_range,-1.0)
        mx = self.input_q_range

        self.tf_var_q = hwqo.tf_quantize(self.tf_var,mn,mx,bw)

    def tf_function_q(self,layer_input):
        """A quantized version of tf_function.

        Implements the tensorflow 2D convolution and uses the quantized
        tf_var_q tensor instead of the floating point tf_var tensor.
        Convolves layer_input (which should also be quantized) with 
        tf_var_q.

        Args:
            layer_input: A tensor input to the layer

        Returns:
            A quantized tensor from the output of the 2D convolution.

        Raises:

        Examples:

        """

        return layer_input + self.tf_var_q

    def bitwidth_change(self, bw_in):
        """Compute the bias layer output bitwidth

        The input bitwidth is used to compute the output bitwidth of the 
        Bias layer. The bitwidth will be used to requantize the output.  The
        bitwidths do not need to be integers.

        The bitwidths represent the log2 of the maximum possible values.

        Args:
            bw_in: The bitwidth of the input to the bias layer
        Returns:
            bw_out: The bitwidth of the output of the bias layer

        """
        bw_out = bw_in + 1
        return bw_out

    def set_q_out_range(self):
        """Compute quantized output range
        """ 
        self.output_q_range = self.input_q_range * 2

