import tensorflow as tf
import math

class ConvLayer:

    def __init__(self, name, kx_size, ky_size, kz_size, num_kernels, ix_size, iy_size, iz_size, sharing_factor, rq_max, rq_min):
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
        self.kernels = None # empty until trained network is saved
      
        # standard deviation for random weights
        self.w_init_stddev = 0.1
        # tensor flow weight variable
        self.tf_var = tf.Variable(tf.truncated_normal([self.kx_size,
            self.ky_size,
            self.z_size,
            self.num_kernels
            ], stddev=self.w_init_stddev))

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
        self.MA_TREE_SIZE = int(2**math.ceil(math.log(8 * kx_size * ky_size,2)))

        self.rq_max = rq_max
        self.rq_min = rq_min
        

    def write_inst(self,name, in_wire, out_wire):
        inst = "wire [31:0] wire_32_"+str(in_wire)+";\n"
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

  requantize rq_inst_"""+str(in_wire)+""" (
    .clock(clock),
    .reset(reset),
    .pixel_in(wire32_"""+str(in_wire)+"""),
    .max_val("""+str(self.rq_max)+"""),
    .min_val("""+str(self.rq_min)+"""),
    .pixel_out(wire8["""+str(out_wire)+"""])
  );
"""
        return inst

    def write_kernel_wire(self):
        tabs = '                       '
        k_wire = tabs[:-1]+'};' # end of wire
        dim = self.kernels.shape
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
                    k_slice = self.kernels[r,:,z,k]
       
                    row_wire=','
                    # now, iterate over columns and write strings
                    for c in k_slice[::-1]:
                        row_wire = ", 8'd"+str(c)+row_wire
                    k_wire = tabs + row_wire[2:] + '\n' + k_wire
       
                # Add annotation
                annotation = "/* Kernel "+ str(k) + " z="+str(z)+" */"
                k_wire = annotation + k_wire[len(annotation):]


        k_width = self.Z_DEPTH*self.NUM_TREES*self.P_SR_DEPTH*self.NUM_SR_ROWS - 1
        k_declaration = "wire ["+str(k_width)+":0] "+self.kernels_wire_name+";\n"
        k_wire = k_declaration+"assign "+self.kernels_wire_name+" = {\n" + k_wire

        return k_wire 

        
    def export(self, name, in_wire, out_wire):

        inst = write_kernel_wire()
        inst += '\n'
        inst += write_inst(name,in_wire,out_wire)
        return inst
        
    def update_kernels(self,np_kernels):
        # Check kernel size
        k_dim = np_kernels 
        if k_dim != (self.kx_size,self.ky_size,self.kz_size,self.num_kernels):
            raise ValueError("The given kernel size did not match the layer size.\n"+
                    "Kernel size: "+str(k_dim) +
                    "\nLayer size: "+str((self.kx_size,self.ky_size,self.kz_size,self.num_kernels))+"\n")
            
        # Kernel data should be unsigned decimal strings between [0,255]
        self.kernels = np_kernels

    def tf_function(self,layer_input):
        # x: the input to the convolutional layer
        # W: the tensorflow weight parameters of the layer
        return tf.nn.conv2d(layer_input, self.tf_var, strides=[1, 1, 1, 1], padding='VALID')

    def save_trained_layer(self):
        self.kernels = self.tf_var.eval()
