// assume 4x4 kernel
// with 4x4 kernel, tree is 3 registers deep
`timescale 1 ps / 1 ps
module mult_adder_tb();

reg clock;
reg reset;

// mult-add operands
reg [8*4*4-1:0] in;
reg [8*4*4-1:0] kernel;

wire [31:0] out;

// DUT
mult_adder #(
  .MA_TREE_SIZE(4*4)
)
dut (
  .clock(clock),
  .reset(reset),
  .in(in),
  .kernel(kernel),
  .out(out)
);

always begin
  #5 clock <= ~clock;
end

initial begin
  clock = 1'b1;
  reset = 1'b1;
  in = 128'h03030303030303030303030303030303;
  kernel = 128'h02020202020202020202020202020202;
  
  #10
  reset = 1'b0;
  #10
  reset = 1'b1;
  #10
  in = 128'h02020202020202020202020202020202;
  #10
  in = 128'h03030303030303030303030303030303;
  #20
  #10
  $display($time); 
  if (out == 32'd96)
    $display("out = %d, success!", out);
  else
    $display("out = %d, fail!", out);
  #10
  $display($time); 
  if (out == 32'd64)
    $display("out = %d, success!", out);
  else
    $display("out = %d, fail!", out);
  #10
  $display($time); 
  if (out == 32'd96)
    $display("out = %d, success!", out);
  else
    $display("out = %d, fail!", out);

  #20
  $stop;
end

endmodule
