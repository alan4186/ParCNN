import tensorflow as tf
import math
import hw_quantize_ops as hwqo
import numpy as np

class DenseLayer:

    """A Densly connected layer for a neural network in several formats.

    This class implements a densly connected layer with tensorflow floating
    point and 8 bit quantized values.  This class contains the nessesary
    functions to write a verilog module instantiation of this layer.

    """

    def __init__(self, name, ix_size, iy_size, iz_size, output_size, 
            sharing_factor, rq_max, rq_min):
        """DenseLayer Constructor

        Initializes a DenseLayer object. Because the layer is dense, the
        input size is the same as the kernel size, therefore the kernel size
        arguments are ommited.

        Args:
            name: A unique string to identify this layer
            ix_size: The size of the input X dimension
            iy_size: The size of the input Y dimension
            iz_size: The size of the input Z dimension.  It is equal to the
                number of kernels in the previous layer.
            output_size: The size of the 1D output vector.
            sharing_factor: Currently Useless.

        Returns:
            A DenseLayer object.

        Raises:
            ValueError.

        Examples:

        """

        # check that the requantize range is valid
        if rq_min >= rq_max:
            raise ValueError("Invalid requantize range." +
            "rq_min must be less than rq_max. " + 
            "rq_min = "+str(rq_min)+", rq_max = " +str(rq_max))


        self.layer_type = 'dense'
        self.name = name
        self.ix_size = ix_size
        self.iy_size = iy_size
        self.iz_size = iz_size
        self.i_size = ix_size * iy_size * iz_size
        self.o_size= output_size

        # nunber of elements in the port vectors (not the same as bits)
        self.in_port_width = iz_size
        self.out_port_width = output_size

        # empty until a trained network is saved
        self.np_kernels = None 
        # empty until a trained network is saved
        self.np_kernels_q = None 
        # empyer until the trained network is quantized
        self.input_q_range = None 
        # empyer until the trained network is quantized
        self.output_q_range = None 
        # None if no requantization is done after the layer.
        # If requantize is called afte the layer, rq_scale_factor will
        # be set
        self.rq_scale_factor = None
        self.np_rq_scale_factor = None
       
        # for visualization compatability
        self.kx_size = ix_size
        self.ky_size = iy_size
        self.zy_size = iz_size
        self.num_kernels = output_size
      
        # standard deviation for random weights
        self.w_init_stddev = 0.1
        # tensor flow weight variable
        self.tf_var = tf.Variable(tf.truncated_normal([self.kx_size,
            self.ky_size,
            self.iz_size,
            self.num_kernels
            ], stddev=self.w_init_stddev), name=self.name+"_var")

        self.tf_var_q = None # empty until set by quantize function
        self.kernels_wire_name = self.name+"_kernels"

        # compute parameters
        # tree sharing is not implemented yet, each kernel gets its own tree
        self.NUM_TREES = output_size 
        self.Z_DEPTH = iz_size
        self.P_SR_DEPTH = ix_size
        #self.RAM_SR_DEPTH = ix_size - kx_size
        self.NUM_SR_ROWS = iy_size
        # Round the tree size up to the next power of 2 
        # to keep the tree code simple, extra resources should 
        # be optimized away.
        #self.MA_TREE_SIZE = int(2**math.ceil(math.log(8 * ix_size * iy_size,2)))
        self.MA_TREE_SIZE = int(2**math.ceil(math.log(ix_size * iy_size,2)))

        self.rq_max = rq_max
        self.rq_min = rq_min
        

    def write_inst(self,name, in_wire, out_wire):
        """Write a dense layer verilog module instantiation.

        This function converts the properties of the dense layer into a 
        synthesizeable verilog module instantiation.

        Args:
            name: A string containing the name of the verilog module
            in_wire: The name of the verilog wire variable from the previous
                layer.
            out_wire: The name of the verilog wire to connect to the output 
                port of the dense layer module.

        Returns:
            A string with the module instantiations needed to synthesize a
            densly connected layer.

        Raises:

        Examples:

        """

        inst = "wire [32*"+str(self.NUM_TREES)+"-1:0] wire32_"+str(in_wire)+";\n"
        inst +="""
  dense_25D #(
    .NUM_TREES("""+str(self.NUM_TREES)+"""),
    .Z_DEPTH("""+str(self.Z_DEPTH)+"""),
    .P_SR_DEPTH("""+str(self.P_SR_DEPTH)+"""), 
    .NUM_SR_ROWS("""+str(self.NUM_SR_ROWS)+"""),
    .MA_TREE_SIZE("""+str(self.MA_TREE_SIZE)+""")
  )
  """+name+""" (
    .clock(clock),
    .reset(reset),
    .pixel_in(wire8["""+str(in_wire)+"""]),
    .kernel("""+self.kernels_wire_name+"""),
    .pixel_out(wire32_"""+str(in_wire)+""")
  );

  requantize #(
    .SHIFT("""+str(self.np_rq_scale_factor)+"""), 
    .SIZE("""+str(self.NUM_TREES)+""")
  )
  rq_inst_"""+str(in_wire)+""" (
    .clock(clock),
    .reset(reset),
    .pixel_in(wire32_"""+str(in_wire)+"""),
    .pixel_out(wire8["""+str(out_wire)+"""])
  );
"""
        return inst

    def write_kernel_wire(self):
        """Write the quantized kenels to a verilog wire assignment.

        Write a verilog string with a wire declaration and assignment.
        The numpy wuantized kernels are converted to verilog constants and 
        concatenated in the assignment.

        Args:
            None.

        Returns:
            A string with a verilog wire variable.

        """

        # convert negitive values to unsigned equvilants
        unsigned_kernel_q = np.less(self.np_kernels_q,0) * 256.0
        unsigned_kernel_q += self.np_kernels_q
        unsigned_kernel_q = unsigned_kernel_q.astype(int)
    

        tabs = '                       '
        k_wire = tabs[:-2]+'};' # end of wire
        trailing_comma = False
        dim = self.np_kernels_q.shape
        # move down Z dimension
        for z in range(0,dim[2]):
            # move down kernel dimension
            for k in range(0,dim[3]):
                #move down row dimension
                for r in range(0, dim[0]):
                    """ 
                    # dont move down column dim,
                    # select entire rows at a time
        
                    # move down column dimension:
                    for c in dim[1]:
                    """
                    k_slice = unsigned_kernel_q[r,:,z,k]

                    if trailing_comma:
                        row_wire=','
                    else:
                        row_wire=''
                        trailing_comma = True

                    # now, iterate over columns and write strings
                    for c in k_slice[::-1]:
                        row_wire = ", 8'd"+str(c)+row_wire
                    #k_wire = tabs + row_wire[2:] + '\n' + k_wire
                    k_wire = tabs + row_wire[2:]  + k_wire
       
                # Add annotation
                annotation = "/* Kernel "+ str(k) + " z="+str(z)+" */"
                k_wire = annotation + k_wire[len(annotation):]


        k_width = self.Z_DEPTH*self.NUM_TREES*self.P_SR_DEPTH*self.NUM_SR_ROWS - 1
        k_declaration = "wire ["+str(k_width)+":0] "+self.kernels_wire_name+";\n"
        k_wire = k_declaration+"assign "+self.kernels_wire_name+" = {\n" + k_wire

        return k_wire 

        
    def export(self, name, in_wire, out_wire):
        """Convert the tensorflow version to a synthsizeable verilog

        Convert the tensor in tf_var_q to a verilog wire and write the
        module instantiation to a string.

        Args:
            name: A string containing the name of the verilog module
            in_wire: The name of the verilog wire variable from the previous
                layer.
            out_wire: The name of the verilog wire to connect to the output 
                port of the dense layer module.

        Returns:
            A string with the kernel tensor in a verilog wire variable
            followed by module instantiations to implement the dense layer.

        Raises:

        Examples:

        """

        inst = self.write_kernel_wire()
        inst +='\n'
        inst += self.write_inst(name, in_wire, out_wire)
        return inst
    """  
    def update_kernels(self,np_kernels):
        # Check kernel size
        k_dim = np_kernels 
        if k_dim != (self.ix_size,self.iy_size,self.iz_size,self.o_size):
            raise ValueError("The given kernel size did not match the layer size.\n"+
                    "Kernel size: "+str(k_dim) +
                    "\nLayer size: "+str((self.ix_size,self.iy_size,self.iz_size,self.o_size))+"\n")
            
        # Kernel data should be unsigned decimal strings between [0,255]
        self.kernels = np_kernels
    """
    def tf_function(self,layer_input, dropout=1):
        """Wrap the tensorflow operations performed by the layer

        This module implements the tensorflow operations to compute the
        the output of a dense layer.  This layer will use similar verilog
        as the 2D convolution layer and is implemented with the same 
        convolution function using two inputs of the same size and the 
        'valid' padding resulting in a fully connected layer with one output
        for each kernel.

        Args:
            layer_input: The tensor output by the previous layer

        Kwargs:
            dropout: The probability used in the dropout function.  
                Defalut is 1.  Testing and inference should use a value of
                1, traingin can use a value in the range (0,1].

        Raises:

        Examples:

        """

        # flatten the layer_input
        in_flat = tf.reshape(layer_input,[-1,self.i_size])
        # dont flaten the output to maintain compatability with hardware
        return tf.nn.dropout(tf.nn.conv2d(layer_input, self.tf_var, strides=[1, 1, 1, 1], padding='VALID'), dropout)
        #out = tf.nn.conv2d(layer_input, self.tf_var, strides=[1, 1, 1, 1], padding='VALID')
        #return tf.reshape(out,[-1,self.o_size])

    def save_layer(self, fd):
        """Evaluate the tensor version of the layer and save result.

        Evaluate the floating point version of the layer and save the
        resulting numpy matrix to the variable np_kernels.  The quantized 
        version needs the test data feed_dict. The data in the dictionary
        should be the testing data such as MNIST.test.images

        Args:
            fd: The feed_dict used in the test section of the training loop


        """

        np_kernels = self.tf_var.eval()
        np_kernels_q = self.tf_var_q.eval(feed_dict=fd)
        # Check kernel size
        k_dim = np_kernels.shape
        if k_dim != (self.ix_size,self.iy_size,self.iz_size,self.o_size):
            raise ValueError("The given kernel size did not match the layer size.\n"+
                    "Kernel size: "+str(k_dim) +
                    "\nLayer size: "+str((self.ix_size,self.iy_size,self.iz_size,self.o_size))+"\n")
            
        # Kernel data should be unsigned decimal strings between [0,255]
        self.np_kernels = np_kernels 
        self.np_kernels_q = np_kernels_q
        if self.rq_scale_factor != None:
            self.np_rq_scale_factor = self.rq_scale_factor.eval(feed_dict=fd).astype(int)
        

    def quantize(self, bw):
        """Convert the floating point tensor to an integer tensor.

        Convert the tensor in tf_var into a quantized tensor. The range
        gieven by mn (the minimum) and mx (the maximum) must be symetric.  
        The bitwith of the quantized tensor is given by bw but has only been
        tested at 8 bits.  The verilog output will not synthesize if a
        different bitwidth is used. The mn, mx and bw arguments should be
        tensors but floating point numbers will probably work too as
        tensorflow can converte them to tensors automatically.  The 
        resluting quantized tensor is stored in tf_var_q.

        Quantization is achieved by dividing the range into 2^bw linearly 
        spaced values.  The resluting integers are signed.

        Args:
            mn: The minimum of the quantization range. Must equal -1 * mx.
                Should be a constant tensor with a floating point value.
            mx: The maximum of the quantization range. Must equal -1 * mn.
                Should be a constant tensor with a floating point value.
            bw: The bitwidth of the quantized reslut. Should be a constant
                floating point tensor with an integer value.

        """
        mn = tf.multiply(self.input_q_range,-1.0)
        mx = self.input_q_range

        self.tf_var_q = hwqo.tf_quantize(self.tf_var, mn,mx,bw)

    def tf_function_q(self,layer_input):
        """Wrap the tensorflow ops for the quantized dense layer.
        
        This function is nearly identical to tf_function exept that this one
        uses the quantized tensor tf_var_q as an input instead of the
        floating point version.  Again, the tensorflow 2D convolution
        function is used to implement a dense layer by using the 'valid'
        padding and two inputs of equal size resulting in a densly connected
        layer with an output for each kernel.

        Args:
            layer_input: The quantized tensor from the previous layer.

        Returns:
            The quantized tensor resulting from the 2D convolution of the 
            input tensors.

        """

        # flatten the layer_input
        #in_flat = tf.reshape(layer_input,[-1,self.i_size])
        # dont flaten the output to maintain compatability with hardware
        return tf.nn.conv2d(layer_input, self.tf_var_q, strides=[1, 1, 1, 1], padding='VALID')


    def bitwidth_change(self, bw_in):
        """Compute the bitwidth of the dense layer output

        Use the bitwidth of the input to compute the bitwidth of the output.
        The output bitwidth does not need to be an integer and will be used
        to requantize the output. 

        The bitwidths represent the log2 of the maximum possible values.

        Args:
            bw_in: The bitwidth of the input
                                                            
        Returns:
            bw_out: The bitwidth of the output
        """
        adder_depth = math.log(self.i_size, 2)
        bw_out = 2 * bw_in + adder_depth - 1
        return bw_out

    def set_q_out_range(self):
        """Compute the maximum quantized output

        Use the input_q_range value to compute the output_q_range value.

        """
        self.output_q_range = hwqo.conv_max(self.input_q_range, self.i_size)
