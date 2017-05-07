// This module is part the dense (fully connected) layer module,
// it is implemented as a 2D convolution where the kernel size 
// equals the input size.

module dense_2D #(
  parameter NUM_TREES = -1,
  // shift reg parameters
  parameter P_SR_DEPTH = -1, 
  parameter NUM_SR_ROWS = -1, // the y dimension of the parallel out 'window'
  // mult adder tree parameters
  parameter MA_TREE_SIZE = -1,
  parameter PAD_SIZE = -1
)(
  input clock,
  input reset,

  input [7:0] pixel_in,
  input [8*NUM_TREES*MA_TREE_SIZE-1:0] kernel,

  output [32*NUM_TREES-1:0] pixel_out
);

// reg declarations
// wire declarations
wire [8*(MA_TREE_SIZE-PAD_SIZE)-1:0] window_wire [NUM_TREES-1:0];
wire [8*MA_TREE_SIZE-1:0] window_wire_padded [NUM_TREES-1:0];
// assign statments

genvar i;
generate

for(i=0; i<NUM_TREES; i=i+1) begin : pad_loop
  assign window_wire_padded[i] = { {PAD_SIZE{8'd0}}, window_wire[i] };
end

// generate the trees
for(i=0; i<NUM_TREES; i=i+1) begin : tree_loop
  mult_adder #(
    .MA_TREE_SIZE(MA_TREE_SIZE)
  )
  ma_inst (
    .clock(clock),
    .reset(reset),
    .in(window_wire_padded[i]),
    .kernel(kernel[i*8*MA_TREE_SIZE+8*MA_TREE_SIZE-1:i*8*MA_TREE_SIZE]),
    .out(pixel_out[i*32+31:i*32])
  );
end

// generate the shift registers
// for now there will be one register for each tree
for(i=0; i<NUM_TREES; i=i+1) begin : sr_loop 
  dense_sr #(
    .P_SR_DEPTH(P_SR_DEPTH),
    .NUM_SR_ROWS(NUM_SR_ROWS)
  )
  dense_sr_inst (
    .clock(clock),
    .reset(reset),
    .shift_in(pixel_in),
    .p_window_out(window_wire[i])
  );
end 

endgenerate


endmodule
