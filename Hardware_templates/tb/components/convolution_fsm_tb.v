`timescale 1 ps / 1 ps
module convolution_fsm_tb ();

parameter P_SR_DEPTH = 2;
parameter RAM_SR_DEPTH = 4;
parameter NUM_SR_ROWS = 4;
parameter MA_TREE_SIZE = 16;
parameter MA_TREE_DEPTH = 4; // log2(MA_TREE_SIZE)

reg clock;
reg reset;
reg row_shift_in_rdy;
reg input_start;

wire sr_enable;
wire shift_row_up;
wire conv_done;

// DUT
convolution_fsm #(
  .P_SR_DEPTH(P_SR_DEPTH),
  .RAM_SR_DEPTH(RAM_SR_DEPTH),
  .NUM_SR_ROWS(NUM_SR_ROWS),
  .MA_TREE_SIZE(MA_TREE_SIZE),
  .MA_TREE_DEPTH(MA_TREE_DEPTH)
)
dut (
  .clock(clock),
  .reset(reset),
  .row_shift_in_rdy(row_shift_in_rdy),
  .input_start(input_start),
  .sr_enable(sr_enable),
  .shift_row_up(shift_row_up),
  .conv_done(conv_done)
);

always begin
  #5 clock <= ~clock;
end

initial begin
  $display("###################");
  $display("convolution_fsm #");
  $display("###################");

  clock = 1'b1;
  reset = 1'b1;
  row_shift_in_rdy = 1'b1;
  input_start = 1'b0;

  #10
  reset = 1'b0;
  #10
  reset = 1'b1;
  #20
  input_start = 1'b1;
  #10
  input_start = 1'b0;
  #30 // wait 4 clock cycles for shift row up
      // wait starts the same clock cycle that input start is asserted
  $display("Time = %0d",$time);
  if (shift_row_up == 1'b1 )
    $display("shift_row_up = %0d\n\t\t\tPASS!", shift_row_up);
  else
    $display("shift_row_up = %0d\n\t\t\tFAIL!", shift_row_up);
  #40 // wait 4 clock cycles for shift row up
  $display("Time = %0d",$time);
  if (shift_row_up == 1'b1 )
    $display("shift_row_up = %0d\n\t\t\tPASS!", shift_row_up);
  else
    $display("shift_row_up = %0d\n\t\t\tFAIL!", shift_row_up);
  #40 // wait 4 clock cycles for shift row up
  $display("Time = %0d",$time);
  if (shift_row_up == 1'b1 )
    $display("shift_row_up = %0d\n\t\t\tPASS!", shift_row_up);
  else
    $display("shift_row_up = %0d\n\t\t\tFAIL!", shift_row_up);

  #40 // wait 4 clock cycles for adder tree output
  $display("Time = %0d",$time);
  if (conv_done == 1'b1 )
    $display("conv_done = %0d\n\t\t\tPASS!", conv_done );
  else
    $display("conv_done = %0d\n\t\t\tFAIL!", conv_done );

  #20
  row_shift_in_rdy = 1'b0;
  #20
  row_shift_in_rdy = 1'b1;
  #20
  $display("Time = %0d",$time);
  if (shift_row_up == 1'b1 )
    $display("shift_row_up = %0d\n\t\t\tPASS!", shift_row_up);
  else
    $display("shift_row_up = %0d\n\t\t\tFAIL!", shift_row_up);

  #20
  $stop;

end // initial block
endmodule

