// assume 4x4 kernel
// with 4x4 kernel, tree is 3 registers deep
`timescale 1 ps / 1 ps
module adder_tree_32bit_tb();

parameter TREE_SIZE = 8;

reg clock;
reg reset;

// add operands
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
  $display("#######################");
  $display("adder_tree_32bit_tb #");
  $display("#######################");
  clock = 1'b1;
  reset = 1'b1;

  in = {32'd1, 32'd2, 32'd3, 32'd4, 32'd120, 32'd6, 32'd66, 32'd8 }; // =210

  #10
  reset = 1'b0;
  #10
  reset = 1'b1;
  #10
  in = {32'd9, 32'd8, 32'd249, 32'd0, 32'd240, 32'd6, 32'd7, 32'd8 }; // =38
  #10
  in = {32'd0, 32'd2, 32'd216, 32'd4, 32'd7, 32'd243, 32'd7, 32'd2 }; // =-31 = 32'hffffffe1
  #10
  $display("Time = %0d",$time); 
  if (out == 32'd210)
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);
  #10
  $display("Time = %0d",$time); 
  if (out == 32'd15)
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);
  #10
  $display("Time = %0d",$time); 
  if (out == 32'hffffffe1)
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);

  #20
  $display("\n");
  $stop;
end

endmodule
