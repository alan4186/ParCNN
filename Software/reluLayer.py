import tensorflow as tf
import math
import hw_quantize_ops as hwqo

class ReluLayer:
    """Rectified linear activation function.

    This class implements the rectified linear activation function for 
    floating point and quantized values.

    """

    def __init__(self, name, size, q_max, q_min):
        """ReluLayer constructor.

        Initialize a ReluLayer object.  The quantized range is not
        known until training time.  When the quantied version is needed,
        the quantezed value of zero should be computed and input to the 
        tf_function_q function.

        Args:
            name: A unique string to identify this layer.
            size: The number of Relu units in the layer.

        Returns:
            An ReluLayer object.

        Raises:

        Examlpe:


        """

        self.layer_type = 'relu'
        self.name = name
        self.size = size

        # number of elements in the ports (not the same as bits)
        self.in_port_width = size
        self.out_port_width = size

        self.q_max = q_max
        self.q_min = q_min
        # The value of zero relative to the input, 
        # will not be 0 for quantized ops
        self.tf_var = 0.0 
        # empty until set by quantize function
        self.tf_var_q = None 
        # empty until the trained network is quantized
        self.input_q_range = None 
        # empty until the trained network is quantized
        self.output_q_range = None             
        
        
        # Parameters
        self.SIZE = size


    def write_inst(self,name, in_wire, out_wire):
        """Write a string with a veilog relu module instantiation.

        Create a verilog module instantiation based on the current class
        variables.

        Args:
            name: A string containing the name of the module instanitaion.
            in_wire: A string with the name of the verilog wire variable
                to connect to the input port of the module instantiation.
            out_wire: A string with the name of the verliog wire variable
                to conect to the output port of the module instantiatoin.

        Returns:
            A string with the verilog module instantiation.

        Raises:

        Examples:


        """


        inst ="""
  relu #(
    .SIZE("""+str(self.SIZE)+""")
  )
  """+name+""" (
    .clock(clock),
    .reset(reset),
    .in(wire8["""+str(in_wire)+"""]),
    .out(wire8["""+str(out_wire)+"""])
  );

"""
        return inst
        
    def export(self, name, in_wire, out_wire):
        """Convert the layer to a verilog module.

        Call all of the nessesary functions to create a synthesizeable 
        verilog module.

        Args:
            name: The name of the module instantiation.
            in_wire: A string with the name of the verilog wire variable
                to connect to the input port of the module instantiation.
            out_wire: A string with the name of the verliog wire variable
                to conect to the output port of the module instantiatoin.

        Returns:
            A string with the verilog module instantiation.

        Raises:

        Examples:

        """

        return self.write_inst(name,in_wire,out_wire)
       
    def tf_function(self,layer_input,dropout=1):
        """Compute the activation function result.

        Use the Tensorflow relu function to compute the activation function
        reslut.  A dropout probability may be given but will be ignored.
        Dropout probablility is included to keep the args the same for all
        tf_functions in all layer classes.

        Args;
            layer_input: A tensor from the previous layer to rectify.

        Kwargs:
            dropout: A useless argument kept to keep tf_function calls
                uniform, simplifying network creation. Can be any value.

        Returns:
            A tensor the same size as the input where all negative values 
            have been set to 0 and all positive values have not been changed

        Raises:

        Example:

        """
        return tf.nn.relu(layer_input)

    def save_layer(self, fd):
        """Save the layer parameters

        """
        return None

    def quantize(self, bw):
        """Quantize the rectified linear layer.

        The layer is quantized by determining the quantized value of 0 so
        it can be fed into the tf_function_q function. The quantization
        range is diveded into 2^bw lineraly spaced bins.

        Args:
            mn: A tensor with the floating point minimum quantization range.
            mx: A tensor with the floating point maximum quantization range.
            bw: The number of bits in the quantized output.

        Returns:
            Nothing.

        Raises:

        Example:

        """
        mn = tf.multiply(self.input_q_range,-1.0)
        mx = self.input_q_range
        self.tf_var_q = hwqo.tf_quantize(self.tf_var,mn,mx,bw)

    def tf_function_q(self,layer_input):
        """A quantized version of the rectified linear activation function.

        The rectified linear activation function is computed by finding the 
        element wise maximum between layer_input and 0.  Because the 
        quantization is signed, the default tensorflow relu function is
        still accurate.

        Args:
            layer_input: A quantized tensor output from the previous layer.

        """
        return tf.nn.relu(layer_input)

    def bitwidth_change(self, bw_in):
        """Compute the bitwidth of the relu layer output.

        The rectified linear layer does not perform any multiplication or 
        addition and therefor does not change the bitwidth of the input.
        Simply return the given input bitwidth.

        Args:
            bw_in: The bitwidth of the input to the relu layer
        Returns:
            bw_in: The bitwidth of the input to the relu layer

        """
        return bw_in

    def set_q_out_range(self):
        """Compute quantized output range
        """ 
        self.output_q_range = self.input_q_range
