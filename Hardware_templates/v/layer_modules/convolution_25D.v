// 2.5D convolution.  This module does 2D convolution element wise along
// a third dimension
module convolution_25D #(
  parameter NUM_TREES = -1, // equal to number of kernels if the trees are not shared
  parameter Z_DEPTH = -1, // equal to the number of kernels in the previous layer
  // shift reg parameters
  parameter P_SR_DEPTH = -1, 
  parameter RAM_SR_DEPTH = -1, 
  parameter NUM_SR_ROWS = -1, // the y dimension of the parallel out 'window'
  // mult adder tree parameters
  parameter MA_TREE_SIZE = -1
)(
  input clock,
  input reset,

  input [8*Z_DEPTH-1:0] pixel_vector_in,
  input [8*NUM_TREES*MA_TREE_SIZE*Z_DEPTH-1:0] kernel,

  output [32*NUM_TREES-1:0] pixel_vector_out
);

wire [32*NUM_TREES-1:0] [Z_DEPTH-1:0] conv_to_tree_wire;

genvar i;
generate
// generate the 2d convolution
for(i=0; i<Z_DEPTH; i=i+1) begin : 2D_conv_loop
  convolution_2D #(
    .NUM_TREES(NUM_TREES),
    .P_SR_DEPTH(P_SR_DEPTH),
    .RAM_SR_DEPTH(RAM_SR_DEPTH),
    .NUM_SR_ROWS(NUM_SR_ROWS),
    .MA_TREE_SIZE(MA_TREE_SIZE)
  )
  conv_2d_inst (
    .clock(clock),
    .reset(reset),
    .pixel_in(pixel_vector_in[i*8+7:i*8]),
    .kernel(kernel[8*NUM_TREES*MA_TREE_SIZE+
                   8*NUM_TREES*MA_TREE_SIZE-1:
                   8*NUM_TREES*MA_TREE_SIZE
                  ]
            ),
    .pixel_out(conv_to_tree_wire[32*NUM_TREES-1:0][i])
  );
end

// sum the outputs in the Z direction
for(i=0; i<NUM_TREES; i=i+1) begin : z_loop
  adder_tree_32bit #(
    .TREE_SIZE(TREE_SIZE)
  )
  adder_tree_inst (
    .clock(clock),
    .reset(reset),
    .in(conv_to_tree_wire[i*32+31:i*32][Z_DEPTH-1:0]),
    .out(pixel_vector_out[i*32+31:i*32])
  );

end
endgenerate

endmodule
