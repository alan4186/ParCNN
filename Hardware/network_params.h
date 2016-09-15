// General Network Parameters
`define INPUT_SIZE 28 // dimension of square input image
`define NUM_KERNELS 10
`define KERNEL_SIZE 9 // square kernel
`define FEATURE_SIZE `INPUT_SIZE - KERNEL_SIZE + 1 // The dimension of the convolved image

// General Bitwidths
`define NN_WIDTH 16
`define NN_BITWIDTH `NN_WIDTH - 1

// Sub sampling
`define NEIGHBORHOOD_SIZE 4
`define NH_VECTOR_WIDTH `NEIGHBORHOOD_SIZE*`NN_WIDTH
`define NH_VECTOR_BITWIDTH `NH_VECTOR_WIDTH - 1 
`define NUM_NH_LAYERS CLOG(`NEIGHBORHOOD_SIZE)
`define ADDER_TREE_BITWIDTH `NN_BITWIDTH+`NUM_NH_LAYERS

// Softmax 
`define SOFTMAX_IN_VECTOR_LENGTH TBD // the number of inputs to the softmax layer
`define NUM_CLASSES 10 // number of output classes for the entire nn

// Normalization (for Softmax)
`define NUM_NORM_LAYERS `CLOG(`NUM_CLASSES) ????

// Matrix multiply (for Softmax)
`define NUM_INPUT_IM 1 // The number of images input to the layer at a time
`define NUM_INPUT_N  `NUM_KERNELS * `FEATURE_SIZE * `FEATURE_SIZE // The number of input neurons to the layer
`define NUM_OUTPUT_N `NUM_OUTPUT_CLASSES
`define FFN_WIDTH TBD // The width of the inputs to the feed forward network
`define FFN_BITWIDTH `FFN_WIDTH - 1
`define FFN_OUT_WIDTH `FFN_WIDTH * 2 + `CLOG2(`NUM_INPUT_N) // The width of the outputs of the feed forward network
`define FFN_OUT_BITWIDTH `FFN_OUT_WIDTH - 1 

// Math macros
`define CLOG2(x) \
    (x <= 2) ? 1 : \
    (x <= 4) ? 2 : \
    (x <= 8) ? 3 : \
    (x <= 16) ? 4 : \
    (x <= 32) ? 5 : \
    (x <= 64) ? 6 : \
    (x <= 128) ? 7 : \
    (x <= 256) ? 8 : \
    (x <= 512) ? 9 : \
    (x <= 1024) ? 10 : \
    (x <= 2048) ? 11 : \
    (x <= 4096) ? 12 : \
    INVALID_LOG
