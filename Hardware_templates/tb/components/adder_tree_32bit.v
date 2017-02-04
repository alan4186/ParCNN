// assume 4x4 kernel
// with 4x4 kernel, tree is 3 registers deep
`timescale 1 ps / 1 ps
module adder_tree_32bit_tb();

parameter TREE_SIZE = 8;

reg clock;
reg reset;

// mult-add operands
reg [32*TREE_SIZE-1:0] in;

wire [31:0] out;

// DUT
adder_tree_32bit #(
  .TREE_SIZE(TREE_SIZE)
)
dut (
  .clock(clock),
  .reset(reset),
  .in(in),
  .out(out)
);

always begin
  #5 clock <= ~clock;
end

initial begin
  clock = 1'b1;
  reset = 1'b1;

  in = {32'd1, 32'd2, 32'd3, 32'd4, 32'd5, 32'd6, 32'd7, 32'd8 }; // =36

  #10
  reset = 1'b0;
  #10
  reset = 1'b1;
  #10
  in = {32'd9, 32'd8, 32'd7, 32'd0, 32'd16, 32'd6, 32'd7, 32'd8 }; // =61
  #10
  in = {32'd0, 32'd2, 32'd5, 32'd4, 32'd7, 32'd6, 32'd7, 32'd2 }; // =33
  #20
  $display($time); 
  if (out == 32'd36)
    $display("out = %d, success!", out);
  else
    $display("out = %d, fail!", out);
  #10
  $display($time); 
  if (out == 32'd61)
    $display("out = %d, success!", out);
  else
    $display("out = %d, fail!", out);
  #10
  $display($time); 
  if (out == 32'd33)
    $display("out = %d, success!", out);
  else
    $display("out = %d, fail!", out);

  #20
  $stop;
end

endmodule
