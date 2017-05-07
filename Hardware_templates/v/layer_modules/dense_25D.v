module dense_25D #(
  parameter NUM_TREES = -1, // equal to number of kernels if the trees are not shared
  parameter Z_DEPTH = -1, // equal to the number of kernels in the previous layer
  // shift reg parameters
  parameter P_SR_DEPTH = -1, 
  parameter NUM_SR_ROWS = -1, // the y dimension of the parallel out 'window'
  // mult adder tree parameters
  parameter MA_TREE_SIZE = -1,
  parameter PAD_SIZE = -1

)(
  input clock,
  input reset,

  input [8*Z_DEPTH-1:0] pixel_vector_in,
  input [8*NUM_TREES*MA_TREE_SIZE*Z_DEPTH-1:0] kernel,

  output [32*NUM_TREES-1:0] pixel_vector_out
);

wire [32*Z_DEPTH-1:0] dense_to_tree_wire [NUM_TREES-1:0];
wire [32*NUM_TREES-1:0] dense_to_tree_wire_t [Z_DEPTH-1:0];


genvar i;
genvar j;
generate
// transpose dense_to_tree_wire 
for(j=0; j<NUM_TREES; j=j+1) begin : kernel_loop
  for(i=0; i<Z_DEPTH; i=i+1) begin : z_loop
    // assign dense_to_tree_wire_t[i][j*32+31:j*32] = dense_to_tree_wire[j][i*32+31:i*32];
    assign dense_to_tree_wire[j][i*32+31:i*32] = dense_to_tree_wire_t[i][j*32+31:j*32];
  end // for i
end // for j

// generate the 2d dense layers
for(i=0; i<Z_DEPTH; i=i+1) begin : dense_25D_loop
  dense_2D #(
    .NUM_TREES(NUM_TREES),
    .P_SR_DEPTH(P_SR_DEPTH),
    .NUM_SR_ROWS(NUM_SR_ROWS),
    .MA_TREE_SIZE(MA_TREE_SIZE),
    .PAD_SIZE(PAD_SIZE)
  )
  dense_2d_inst (
    .clock(clock),
    .reset(reset),
    .pixel_in(pixel_vector_in[i*8+7:i*8]),
    .kernel(kernel[8*NUM_TREES*MA_TREE_SIZE*i+
                   8*NUM_TREES*MA_TREE_SIZE-1:
                   8*NUM_TREES*MA_TREE_SIZE*i
                  ]
            ),
    .pixel_out(dense_to_tree_wire_t[i]) // work
  );
end

// sum the outputs in the Z direction
for(i=0; i<NUM_TREES; i=i+1) begin : z_loop
  adder_tree_32bit #(
    .TREE_SIZE(Z_DEPTH)
  )
  adder_tree_inst (
    .clock(clock),
    .reset(reset),
    .in(dense_to_tree_wire[i]), 
    .out(pixel_vector_out[i*32+31:i*32])
  );

end
endgenerate

endmodule
