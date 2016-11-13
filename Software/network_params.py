import math

# print resourse usage estimates?
estimate_resources = 1

# General Network Parameters
INPUT_SIZE = 28 # dimension of square input image
NUM_KERNELS = 8
#NUM_KERNELS = 2
KERNEL_SIZE = 7 # square kernel
#KERNEL_SIZE = 3 # square kernel
KERNEL_SIZE_SQ = KERNEL_SIZE**2
FEATURE_SIZE = INPUT_SIZE - KERNEL_SIZE + 1 # The dimension of the convolved image

# Screen resolution
X_RES = 800
Y_RES = 600

# Shift window 
CAMERA_PIXEL_WIDTH = 9
CAMERA_PIXEL_BITWIDTH = CAMERA_PIXEL_WIDTH - 1
BUFFER_W = INPUT_SIZE 
BUFFER_BW = BUFFER_W - 1 
BUFFER_H = INPUT_SIZE
BUFFER_BH = BUFFER_H - 1 
BUFFER_SIZE = BUFFER_W * BUFFER_H
BUFFER_OUT_VECTOR_WIDTH = BUFFER_W * BUFFER_H * CAMERA_PIXEL_WIDTH
BUFFER_OUT_VECTOR_BITWIDTH = BUFFER_OUT_VECTOR_WIDTH - 1
WINDOW_VECTOR_WIDTH = KERNEL_SIZE * KERNEL_SIZE * CAMERA_PIXEL_WIDTH
WINDOW_VECTOR_BITWIDTH = WINDOW_VECTOR_WIDTH - 1

# Window selector 
BUFFER_VECTOR_WIDTH = BUFFER_W * BUFFER_H * CAMERA_PIXEL_WIDTH
BUFFER_VECTOR_BITWIDTH = BUFFER_VECTOR_WIDTH - 1
X_COORD_WIDTH = int(math.ceil(math.log(BUFFER_W,2)))
X_COORD_BITWIDTH = X_COORD_WIDTH - 1 
Y_COORD_WIDTH = int(math.ceil(math.log(BUFFER_H,2)))
Y_COORD_BITWIDTH = Y_COORD_WIDTH - 1 
X_COORD_MAX = INPUT_SIZE - KERNEL_SIZE + 1
Y_COORD_MAX = INPUT_SIZE - KERNEL_SIZE + 1
SCREEN_X_WIDTH = int(math.ceil(math.log(X_RES,2)))
SCREEN_X_BITWIDTH = SCREEN_X_WIDTH - 1
SCREEN_Y_WIDTH = int(math.ceil(math.log(Y_RES,2)))
SCREEN_Y_BITWIDTH = SCREEN_Y_WIDTH - 1

# Shift window control (window_ctrl)
BUFFER_X_POS = 0 # the X/Y position of the shifting window/ buffer on the screen
BUFFER_Y_POS = 0 

# Multiply Adder Tree 
MA_TREE_SIZE = 2**int(math.ceil(math.log(KERNEL_SIZE_SQ,2))) # the number of elements in hte base of the tree, equivilant to the number of multipliers needed in each tree
CONV_MULT_WIDTH = 9
CONV_MULT_BITWIDTH = CONV_MULT_WIDTH - 1
CONV_PRODUCT_WIDTH = CONV_MULT_WIDTH * 2 # the width of the product
CONV_PRODUCT_BITWIDTH = CONV_PRODUCT_WIDTH - 1
CONV_ADD_WIDTH = CONV_PRODUCT_WIDTH + int(math.ceil(math.log(MA_TREE_SIZE,2)))
CONV_ADD_BITWIDTH = CONV_ADD_WIDTH - 1
CARRY_VECTOR_WIDTH = (KERNEL_SIZE**2) - 1; 
RDY_SHIFT_REG_SIZE = int(math.ceil(math.log(KERNEL_SIZE_SQ,2))) + 1 + 1# +1 for rect linar and multipliers
FM_COORD_SR_DEPTH = RDY_SHIFT_REG_SIZE
WINDOW_PAD_WIDTH = (MA_TREE_SIZE - KERNEL_SIZE_SQ) * CONV_MULT_WIDTH
WINDOW_PAD_BITWIDTH = WINDOW_PAD_WIDTH - 1
MULT_PAD_WIDTH = int(math.ceil(math.log(KERNEL_SIZE_SQ,2)))
MULT_ADDER_IN_WIDTH =  MA_TREE_SIZE * CONV_MULT_WIDTH
MULT_ADDER_IN_BITWIDTH = MULT_ADDER_IN_WIDTH - 1 

# General Bitwidths
NN_WIDTH = CONV_ADD_WIDTH
NN_BITWIDTH = NN_WIDTH - 1


# Rect Linear
RECT_IN_WIDTH = CONV_ADD_WIDTH
RECT_IN_BITWIDTH = RECT_IN_WIDTH - 1
RECT_OUT_WIDTH = RECT_IN_WIDTH
RECT_OUT_BITWIDTH = RECT_OUT_WIDTH - 1

# Sub sampling
NUM_POOLERS = NUM_KERNELS
NEIGHBORHOOD_SIZE = 4
NH_DIM = int(math.sqrt(NEIGHBORHOOD_SIZE))
NH_VECTOR_WIDTH = NEIGHBORHOOD_SIZE*NN_WIDTH
NH_VECTOR_BITWIDTH = NH_VECTOR_WIDTH - 1 
NUM_NH_LAYERS = int(math.ceil(math.log(NEIGHBORHOOD_SIZE,2)))
#NUM_NH_LAYERS PNUM_NH_LAYERS
POOL_OUT_WIDTH = NN_WIDTH + NUM_NH_LAYERS 
POOL_OUT_BITWIDTH = POOL_OUT_WIDTH - 1 
MEAN_DIVSION_CONSTANT = str(POOL_OUT_WIDTH) + "'d" + str(NEIGHBORHOOD_SIZE)
# POOL_RESET= 1 # uncomment to add reset signal to sub sampleing/pooling adder tree
POOL_TREE_PAD = POOL_OUT_WIDTH - NN_WIDTH

# Sub Sampling control (nh_shift_reg_ctrl)
NH_WIDTH = CONV_ADD_WIDTH
NH_BITWIDTH = NH_WIDTH - 1
NH_SIZE = NEIGHBORHOOD_SIZE
NH_DIM = int(math.sqrt(NH_SIZE))

# Feature Map Buffer Contorl module
FM_ADDR_WIDTH = int(math.ceil(math.log(FEATURE_SIZE**2,2)))
FM_ADDR_BITWIDTH = FM_ADDR_WIDTH - 1
FM_WIDTH = FEATURE_SIZE # the size of the y dimension of the feature map
ADDR_MAX = FEATURE_SIZE**2
NP_MAX_COUNT = ADDR_MAX # same variable, different name for inside matrix_mult.v
NP_COUNT_WIDTH = FM_ADDR_WIDTH
NP_COUNT_BITWIDTH = FM_ADDR_BITWIDTH

# Softmax 
SOFTMAX_IN_VECTOR_LENGTH = ((FEATURE_SIZE * FEATURE_SIZE) / NEIGHBORHOOD_SIZE ) * NUM_KERNELS  # the number of inputs to the softmax layer
NUM_CLASSES = 4 # number of output classes for the entire nn, MUST BE A POWER OF 2!!! set unneeded class inputs to 0

# Matrix multiply (for Softmax)
NUM_INPUT_IM = 1 # The number of images input to the layer at a time
NUM_INPUT_N  = (NUM_KERNELS * FEATURE_SIZE * FEATURE_SIZE )# The number of input neurons to the layer
NUM_OUTPUT_N = NUM_CLASSES
FFN_IN_WIDTH =  CONV_ADD_WIDTH # The width of the inputs to the feed forward network. Should be the same as the output width of the softmax layer.
FFN_IN_BITWIDTH = (FFN_IN_WIDTH - 1)
FFN_OUT_WIDTH = (FFN_IN_WIDTH * 2) + int(math.ceil(math.log(NUM_INPUT_N,2))) # The width of the outputs of the feed forward network
FFN_OUT_BITWIDTH = (FFN_OUT_WIDTH - 1)
SUM_WIRE_LEN = ( NUM_INPUT_N * 2 ) - 1 # The number of indexes in the adder tree vector

# Normalization (for Softmax)
NORM_IN_WIDTH = FFN_OUT_WIDTH
NORM_IN_BITWIDTH = NORM_IN_WIDTH - 1
NUM_NORM_LAYERS = int(math.ceil(math.log(NUM_CLASSES,2)))
NORM_OUT_WIDTH = NORM_IN_WIDTH + NUM_NORM_LAYERS
NORM_OUT_BITWIDTH = NORM_OUT_WIDTH - 1
# NORM_RESET = 1 # uncomment to add reset signal to normalization adder tree
ADDER_TREE_PAD = NORM_OUT_WIDTH - NORM_IN_WIDTH




"""
LOG2 = "LOG2(x) \
    (x <= 2) ? 1 : \
    (x <= 4) ? 2 : \
    (x <= 8) ? 3 : \
    (x <= 16) ? 4 : \
    (x <= 32) ? 5 : \
    (x <= 64) ? 6 : \
    (x <= 128) ? 7 : \
    (x <= 256) ? 8 : \
    ((x) <= 512) ? 9 : \
    (x <= 1024) ? 10 : \
    (x <= 2048) ? 11 : \
    (x <= 4096) ? 12 : \
    (x <= 8192) ? 13 : \
    (x <= 16384) ? 14 : \
    (x <= 32768) ? 15 : \
    -100000"
"""

if __name__ == "__main__":
    macroList = []
    blacklist = ['__', 'math', 'macroList','blacklist']

 
    for k, v in list(locals().iteritems()):
        if not any(substring in k for substring in blacklist):
            macroList.append((k,v))
            with open("../Hardware/network_params.h", 'w') as f:
                for macro in macroList:
                    f.write("`define " + str(macro[0]) + ' ' + str(macro[1]) + '\n')

    if estimate_resources:
        le = 0;
        mult = 0;
        memory_bits = 0;
        
        # Shift Window usage
        le = le + (BUFFER_SIZE * CAMERA_PIXEL_WIDTH)
        # window xy lookup
        lookup_size = 350 # a guess
        le = le + (lookup_size * KERNEL_SIZE**2)
    
        # mult-adder tree usage
        for i in range(0,NUM_KERNELS):
            mult = mult + (2**math.ceil(math.log(KERNEL_SIZE**2,2)))
            x = KERNEL_SIZE**2
            """
            # optimized tree
            if x % 2:
                le = le + CONV_ADD_WIDTH + 1
                x = x - 1
            
            while x > 0:
                le = le + (x* (CONV_ADD_WIDTH + 1))
                x = x/2
            """
            # unoptimized tree
            le = le + ((CONV_ADD_WIDTH)*((2**math.ceil(math.log(x,2))*2)-1))

        # rect-linear usage
        le = le + (CONV_ADD_WIDTH)
        # buffer 1 usage
        memory_bits = memory_bits + (FEATURE_SIZE*NUM_KERNELS*CONV_ADD_WIDTH)
        # pooling usage
        for i in range(0,NUM_POOLERS):
            le = le + ( (NEIGHBORHOOD_SIZE *2)-1)* NN_WIDTH
            le = le + NN_WIDTH # a guess about division's area
        # buffer 2 usage
        memory_bits = memory_bits + (FEATURE_SIZE*NUM_KERNELS*CONV_ADD_WIDTH)/4
        # matrix mult usage
        mult = mult + NUM_CLASSES
        le = le + (NUM_CLASSES* NN_WIDTH)
        # softmax/ final acivation usgae
        le = le + (NN_WIDTH *2 * NUM_CLASSES)
    
        print "Estimated number of Logic elements: " + str(le)
        print "Estimated number of 9 bit multipliers: " + str(mult)
        print "Estimated number of memory bits: " + str(memory_bits)
