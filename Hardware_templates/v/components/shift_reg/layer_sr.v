/*
     Parallel SR     RAM SR 
     Window
in ->[0,0][1,0][2,0]->[0][1][2][3]->
    >[0,1][1,1][2,1]->[0][1][2][3]->
    >[0,2][1,2][2,2]>

*/
module layer_sr #( 
  parameter P_SR_DEPTH = -1,
  parameter RAM_SR_DEPTH = -1,
  parameter NUM_SR_ROWS = -1 // the y dimension of the parallel out 'window'
)(
  input clock,
  input reset,
  input [7:0] shift_in,

  output [8*P_SR_DEPTH*NUM_SR_ROWS-1:0] p_window_out
);

// reg declarations
// wire declarations
wire [7:0] p_shift_in [NUM_SR_ROWS-1:0];
wire [7:0] p_shift_out [NUM_SR_ROWS-1:0];
wire [8*P_SR_DEPTH-1:0] p_sr_vector [NUM_SR_ROWS-1:0];

// assign statments
assign p_shift_in[0] = shift_in;

genvar i;
generate
// Instantiate Parallel Out Shift Regs
for(i=0; i<NUM_SR_ROWS; i=i+1) begin : p_sr_loop
  parallel_out_sr #(
    .DEPTH(P_SR_DEPTH)
  )
  p_sr_inst (
    .clock(clock),
    .reset(reset),
    .shift_in(p_shift_in[i]),
    .shift_out(p_shift_out[i]),
    .p_out(p_sr_vector[i])
  );
end 

// Instantiate Ram Shift Regs
for(i=0; i<NUM_SR_ROWS-1; i=i+1) begin : ram_sr_loop
  ram_sr #(
    .DEPTH(RAM_SR_DEPTH)
  )
  ram_sr_inst (
    .clock(clock),
    .reset(reset),
    .shift_in(p_shift_out[i]),
    .shift_out(p_shift_in[i+1])
  );
end

// connect p out vectors to window output
for(i=0; i<NUM_SR_ROWS; i=i+1) begin : connect_window_wire
  assign p_window_out[i*8+7:i*8] = p_sr_vector[i];
end

endgenerate

endmodule
