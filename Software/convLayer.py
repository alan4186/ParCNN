import tensorflow as tf
import math
import hw_quantize_ops as hwqo
import numpy as np

class ConvLayer:

    """A Convolutional layer for a neural network in several formats

    This class implements a convolutional layer with tensorflow in floating
    point and quantized 8 bit representation.  The class contains functions
    to write the nessesary strings of a synthesizable verilog version of 
    this layer. 
    
    """

    def __init__(self, name, kx_size, ky_size, kz_size, num_kernels, 
            ix_size, iy_size, iz_size, sharing_factor, rq_max, rq_min):
        """
        Construct convolutional layer class

        The contructor for the convolutional layer class takes dimensions
        of the kernels and the inputs to the layer and initializes the
        class.
        
        Args:
            name: A unique string to identify this layer.
            kx_size: The size of the kernel's X dimension.
            ky_size: The size of the kernel's Y dimension.
            kz_size: The size of the kernel's Z dimension.
            num_kernels: The number of kernels in the layer.
            ix_size: The size of the input data's X dimension.
            iy_size: The size of the input data's Y dimension.
            sharing_factor: Currently Useless.

        Returns:
            A convLayer class object.

        Raises:
            ValueError

        Examples:

        """

        # make sure the kernel size is at least 1 
        # pixel smaller than the input in the x dimension and 
        # the same size as the input in the y dimension
        if ix_size-kx_size < 1:
            raise ValueError('The kernel X dimension must' 
                    + 'be at least 1 less than the input X'
                    + 'dimension. Kernel X size: '
                    + str(kx_size) + ', Input X size: ' +str(ix_size))

        if iy_size-ky_size < 0:
            raise ValueError('The kernel Y dimension must' 
                    + 'be less than or equal to the input Y'
                    +  'dimension. Kernel Y size: '
                    + str(ky_size) + ', Input Y size: ' + str(iy_size))
       
        # check that the z dimension of the kernel and input match
        if kz_size != iz_size:
            raise ValueError("The kernel and input must have " +
                    "the same Z dimension. kz_size = " +
                    str(kz_size)+", iz_size = " + str(iz_size))

        # check that the requantize range is valid
        if rq_min >= rq_max:
            raise ValueError("Invalid requantize range." +
            "rq_min must be less than rq_max. " + 
            "rq_min = "+str(rq_min)+", rq_max = " +str(rq_max))


        self.layer_type = 'conv'
        self.name = name
        self.ix_size = ix_size
        self.iy_size = iy_size
        self.z_size = kz_size
        self.kx_size = kx_size
        self.ky_size = ky_size
        self.num_kernels = num_kernels

        # number of elements in the port vectors (not the same as bits)
        self.in_port_width = kz_size
        self.out_port_width = num_kernels

        # empty until trained network is saved
        self.np_kernels = None
        # empty until trained netwrok is saved
        self.np_kernels_q = None
        # empty until the trained network is quantized
        self.input_q_range = None 
        # empty until the trained network is quantized
        self.output_q_range = None
        # None if no requanitization is done after the layer.
        # If requantize is called after the layer, rq_scale_factor will
        # be set
        self.rq_scale_factor = None
        self.np_rq_scale_factor = None

        # standard deviation for random weights
        self.w_init_stddev = 0.1
        # tensor flow weight variable
        self.tf_var = tf.Variable(tf.truncated_normal([self.kx_size,
            self.ky_size,
            self.z_size,
            self.num_kernels
            ], stddev=self.w_init_stddev), name=self.name+'_var')

        self.tf_var_q = None # empty until layer is quantized
        self.kernels_wire_name = self.name+"_kernels"

        # compute parameters
        # tree sharing is not implemented yet, each kernel gets its own tree
        self.NUM_TREES = num_kernels 
        self.Z_DEPTH = kz_size
        self.P_SR_DEPTH = kx_size
        self.RAM_SR_DEPTH = ix_size - kx_size
        self.NUM_SR_ROWS = ky_size
        # Round the tree size up to the next power of 2 
        # to keep the tree code simple, extra resources should 
        # be optimized away.
        #self.MA_TREE_SIZE = int(2**math.ceil(math.log(8 * kx_size * ky_size,2)))
        self.MA_TREE_SIZE = int(2**math.ceil(math.log(kx_size * ky_size,2)))

        self.rq_max = rq_max
        self.rq_min = rq_min
        

    def write_inst(self,name, in_wire, out_wire):
        """Write the verilog instantiation of the convolution module.

        Create a verilog string to instantiate the convolution module with
        the same parameters as the tf_var_q variable.

        Args:
            name: A string with the name of the instantiated module.
            in_wire: A string with the verilog wire variable for the module
                input port.
            out_wire: A string with the verilog wire variable for the 
                module output port.

        Returns: 
            A string containing a valid verilog instantiation for the
            convolution layer module.

        Raises:

        Example:

        """


        inst = "wire [32*"+str(self.NUM_TREES)+"-1:0] wire32_"+str(in_wire)+";\n"
        inst +="""
  convolution_25D #(
    .NUM_TREES("""+str(self.NUM_TREES)+"""),
    .Z_DEPTH("""+str(self.Z_DEPTH)+"""),
    .P_SR_DEPTH("""+str(self.P_SR_DEPTH)+"""), 
    .RAM_SR_DEPTH("""+str(self.RAM_SR_DEPTH)+"""),
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

        Write a verilog string with a wire declaration and an assignment. 
        The numpy quantized kernels are converted to verilog constants and 
        concatenated in the assignment.  

        Args:
            None.

        Returns:
            A string with a verilog wire variable.

        """

        # convert negitive values to the unsigned equivilant
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
                    #k_slice = self.np_kernels_q[r,:,z,k]
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


        k_width = (self.Z_DEPTH*self.NUM_TREES*self.P_SR_DEPTH*self.NUM_SR_ROWS*8) - 1
        k_declaration = "wire ["+str(k_width)+":0] "+self.kernels_wire_name+";\n"
        k_wire = k_declaration+"assign "+self.kernels_wire_name+" = {\n" + k_wire

        return k_wire 

        
    def export(self, name, in_wire, out_wire):
        """Convert the tensorflow layer to a synthesizeable module.

        Create the nessesary strings and files to sysntesize a convolution
        module.  A string to instantiate the module is created and the 
        kernels are converted to verilog wire variables and included at the
        begining of the string.

        Args:
            name: A string with the name of the instantiated module
            in_wire: A string with the verilog wire variable for the module
                input port.
            out_wire: A string with the verilog wire variable for the 
                module output port.

        Returns:
            A string with a kernel verilog wire variable and a module
            instantiation.

        Raises:

        Example:

        """

        inst = self.write_kernel_wire()
        inst += '\n'
        inst += self.write_inst(name,in_wire,out_wire)
        return inst

    """        
    def update_kernels(self,np_kernels):
        # Check kernel size
        k_dim = np_kernels 
        if k_dim != (self.kx_size,self.ky_size,self.kz_size,self.num_kernels):
            raise ValueError("The given kernel size did not match the layer size.\n"+
                    "Kernel size: "+str(k_dim) +
                    "\nLayer size: "+str((self.kx_size,self.ky_size,self.kz_size,self.num_kernels))+"\n")
            
        # Kernel data should be unsigned decimal strings between [0,255]
        self.np_kernels = np_kernels
    """
    def tf_function(self,layer_input, dropout=1):
        """A wrapper for the tensorflow 2D convolution function.
        
        Implements the 2D convolution with the tensorflow library. The type
        of convolution performed is 'valid' with strides of 1.  The
        layer_input tensor is convolved with the floating point tf_var
        tensor.

        Args:
            layer_input: A tensor input to the layer
            
        Kwargs:
            droput: A value in the range (0,1] representing the dropout
                probability for the layer.  Default is 1.  The value should
                be 1 for testing and inference.

        Returns:
            A tensor output representing the 2D convoluiton of the tf_var
            and the layer_input.

        Raises:

        Example:

        """

        return tf.nn.dropout(tf.nn.conv2d(layer_input, self.tf_var, strides=[1, 1, 1, 1], padding='VALID'), dropout)

    def save_layer(self, fd):
        """Evaluate the tf_var and save result.

        This function should be called in a tensroflow session.  The tf_var
        will be evaluated and the numpy matrix output will be saved to the
        np_kernels variable.

        Args:
            fd: The testing feed_dict used in the training loop.

        Returns: 
            None.

        Raises:
            ValueError.


        """

        np_kernels = self.tf_var.eval()
        np_kernels_q = self.tf_var_q.eval(feed_dict=fd)
        # Check kernel size
        k_dim = np_kernels.shape
        if k_dim != (self.kx_size,self.ky_size,self.z_size,self.num_kernels):
            raise ValueError("The given kernel size did not match the layer size.\n"+
                    "Kernel size: "+str(k_dim) +
                    "\nLayer size: "+str((self.kx_size,self.ky_size,self.kz_size,self.num_kernels))+"\n")
            
        # Kernel data should be unsigned decimal strings between [0,255]
        self.np_kernels = np_kernels
        self.np_kernels_q = np_kernels_q
        if self.rq_scale_factor != None:
            self.np_rq_scale_factor = self.rq_scale_factor.eval(feed_dict=fd).astype(int)

    def quantize(self, bw):
        """A wrapper for the quantization function.

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

        self.tf_var_q = hwqo.tf_quantize(self.tf_var, mn,mx,bw)

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

        Example:

        """

        return tf.nn.conv2d(layer_input, self.tf_var_q, strides=[1, 1, 1, 1], padding='VALID')


    def bitwidth_change(self, bw_in):
        """Compute the bitwidth of the convolution output

        Use the bitwidth of the input to compute the bitwidth of the output.
        The output bitwidth does not need to be an integer and will be used
        to requantize the output.

        Args:
            bw_in: The bitwidth of the input
        
        Returns:
           bw_out: The bitwidth of the output

        """
        adder_depth = math.log(self.kx_size*self.ky_size*self.z_size, 2)
        bw_out = 2 * bw_in + adder_depth - 1
        return bw_out

    def set_q_out_range(self):
        """Compute the maximum quantized output

        Use the input_q_range value to compute the output_q_range value.

        """

        self.output_q_range = hwqo.conv_max(
                self.input_q_range, self.kx_size*self.ky_size*self.z_size)
