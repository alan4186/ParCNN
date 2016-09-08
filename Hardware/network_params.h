`define NN_WIDTH 16
`define NN_BITWIDTH `NN_WIDTH - 1


// Sub sampling
`define NEIGHBORHOOD_SIZE 4
`define NH_VECTOR_WIDTH `NEIGHBORHOOD_SIZE*`NN_WIDTH
`define NH_VECTOR_BITWIDTH NH_VECTOR_WIDTH - 1 
`define NUM_NH_LAYERS CLOG(`NEIGHBORHOOD_SIZE)
`define ADDER_TREE_BITWIDTH `NN_BITWIDTH+`NUM_NH_LAYERS



// Softmax 
`define SOFTMAX_IN_VECTOR_LENGTH TBD // the number of inputs to the softmax layer
`define NUM_CLASSES 10 // number of output classes for the entire nn

// Normalization (for Softmax
`define NUM_NORM_LAYERS `CLOG(`NUM_CLASSES) ????

// Math macros
`define CLOG2(x) \
    (x <= 2) ? 1 : \
    (x <= 4) ? 2 : \
    (x <= 8) ? 3 : \
    (x <= 16) ? 4 : \
    (x <= 32) ? 5 : \
    (x <= 64) ? 6 : \
    INVALID_LOG
