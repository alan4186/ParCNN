`timescale 1 ps / 1 ps
module parallel_out_sr_tb();

reg clock;
reg reset;

reg [7:0] shift_in;

wire [7:0] shift_out;
wire [8*3-1:0] p_out;

// DUT
parallel_out_sr #(
  .DEPTH(3)
)
dut(
  .clock(clock),
  .reset(reset),
  .shift_in(shift_in),
  .shift_out(shift_out),
  .p_out(p_out)
);





endmodule
