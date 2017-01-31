module convolution #(
  parameter NUM_TREES = -1,
  // shift reg parameters
  parameter P_SR_DEPTH = -1, 
  parameter RAM_SR_DEPTH = -1, 
  parameter NUM_SR_ROWS = -1, // the y dimension of the parallel out 'window'
  // mult adder tree parameters
  parameter MA_TREE_SIZE = -1
)(
  input clock,
  input reset,

  input [7:0] pixel_in,

  output [31:0] pixel_out
);

// reg declarations
// wire declarations
wire [MA_TREE_SIZE-1:0] window_wire [NUM_TREES-1:0]; // MA_TREE_SIZE = 8*P_SR_DEPTH*NUM_SR_ROWS
// assign statments

genvar i;
generate
// generate the trees
for(i=0; i<NUM_TREES; i=i+1) begin : tree_loop
  mult_adder #(
    .MA_TREE_SIZE(MA_TREE_SIZE)
  )
  ma_inst (
    .clock(clock),
    .reset(reset),
    .in(window_wire[i]),
    .kernel(),
    .out(pixel_out)
  );
end

// generate the shift registers
// for now there will be one register for each tree
for(i=0; i<NUM_TREES; i=i+1) begin : sr_loop 
  layer_sr #(
    .P_SR_DEPTH(P_SR_DEPTH),
    .RAM_SR_DEPTH(RAM_SR_DEPTH),
    .NUM_SR_ROWS(NUM_SR_ROWS)
  )
  conv_sr (
    .clock(clock),
    .reset(reset),
    .shift_in(pixel_in),
    .p_window_out(window_wire[i])
  );
end 

endgenerate




endmodule
