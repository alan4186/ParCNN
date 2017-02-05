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

wire [32*Z_DEPTH-1:0] conv_to_tree_wire [NUM_TREES-1:0];
wire [32*NUM_TREES-1:0] conv_to_tree_wire_t [Z_DEPTH-1:0];


genvar i;
genvar j;
generate
// transpose conv_to_tree_wire 
for(j=0; j<NUM_TREES; j=j+1) begin : kernel_loop
  for(i=0; i<Z_DEPTH; i=i+1) begin : z_loop
    // assign conv_to_tree_wire_t[i][j*32+31:j*32] = conv_to_tree_wire[j][i*32+31:i*32];
    assign conv_to_tree_wire[j][i*32+31:i*32] = conv_to_tree_wire_t[i][j*32+31:j*32];
  end // for i
end // for j
// generate the 2d convolution
for(i=0; i<Z_DEPTH; i=i+1) begin : conv_25D_loop
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
    .kernel(kernel[8*NUM_TREES*MA_TREE_SIZE*i+
                   8*NUM_TREES*MA_TREE_SIZE-1:
                   8*NUM_TREES*MA_TREE_SIZE*i
                  ]
            ),
    .pixel_out(conv_to_tree_wire_t[i])
  );
end

// sum the outputs in the Z direction
for(i=0; i<NUM_TREES; i=i+1) begin : z_loop
  adder_tree_32bit #(
    //.TREE_SIZE(NUM_TREES)
    .TREE_SIZE(Z_DEPTH)
  )
  adder_tree_inst (
    .clock(clock),
    .reset(reset),
    .in(conv_to_tree_wire[i]),
//    .in(conv_to_tree_wire[Z_DEPTH-1:0][i*32+31:i*32]),
    .out(pixel_vector_out[i*32+31:i*32])
  );

end
endgenerate

endmodule
