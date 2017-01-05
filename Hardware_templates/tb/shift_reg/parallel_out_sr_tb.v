module parallel_out_sr_tb();

reg clock;
reg reset;

reg [7:0] shift_in;

wire [7:0] shift_out;
wire [8*3-1] p_out;

// DUT
parallel_out_sr #(
  .DEPTH(3)
)(
  .clock(clock),
  .reset(reset),
  .shift_in(shift_in),
  .shift_out(shift_out),
  .p_out(p_out)
);
