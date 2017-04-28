`timescale 1 ps / 1 ps
module relu_tb();

parameter MIN_MSB = 6;
parameter SIZE = 4;

reg clock;
reg reset;

reg [8*SIZE-1:0] in;
reg [7:0] zero;
//reg [7:0] zero_a = 8'd128;
//reg [7:0] zero_b = 8'd32;
//reg [7:0] zero_c = 8'd44;

wire [8*SIZE-1:0] out;
// DUT
relu #(
  .MIN_MSB(MIN_MSB),
  .SIZE(SIZE)
)
dut (
  .clock(clock),
  .reset(reset),
  .zero(zero),
  .in(in),
  .out(out)
);

always begin
  #5 clock <= ~clock;
end

initial begin
  clock = 1'b1;
  reset = 1'b1;
  in = {8'd255, 8'd128, 8'd64, 8'd32};
  zero = 8'd128;

  #10
  reset = 1'b0;

  #10
  reset = 1'b1;

  #10
  $display($time); 
  if (out == {8'd255, 8'd128, 8'd128, 8'd128})
    $display("out = %d, success!", out);
  else
    $display("out = %d, fail!", out);

  // next zero value
  zero = 8'd32;

  #10
  $display($time); 
  if (out == {8'd255, 8'd128, 8'd64, 8'd32})
    $display("out = %d, success!", out);
  else
    $display("out = %d, fail!", out);

  // next zero value
  zero = 8'd44;

  #10
  $display($time); 
  if (out == {8'd255, 8'd128, 8'd64, 8'd44})
    $display("out = %d, success!", out);
  else
    $display("out = %d, fail!", out);

  #20
  $stop;
end

endmodule
