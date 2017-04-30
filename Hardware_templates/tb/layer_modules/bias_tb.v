`timescale 1 ps / 1 ps
module bias_tb();

parameter SIZE = 4;

reg clock;
reg reset;

reg [8*SIZE-1:0] a;
reg [8*SIZE-1:0] b;
wire [9*SIZE-1:0] out;

// DUT
bias #(
  .SIZE(SIZE)
)
dut (
  .clock(clock),
  .reset(reset),
  .a(a),
  .b(b),
  .sum(out)
);

always begin
  #5 clock <= ~clock;
end

initial begin
  $display("###########");
  $display("bias_tb #");
  $display("###########");
  clock = 1'b1;
  reset = 1'b1;
  a = {8'd1, 8'd2,8'd3,8'd4};
  b = {8'd1, 8'd2,8'd3,8'd4};
  

  #10
  reset = 1'b0;

  #10
  reset = 1'b1;
  
  
  #10
  $display("Time = %0d",$time);
  if (out == {9'd2, 9'd4, 9'd6, 9'd8})
    $display("out = %h\n\t\t\tPASS!", out);
  else
    $display("out = %h\n\t\t\tFAIL!", out);

  // next values
  a = {8'he1, 8'h9c,8'd53,8'd94};
  b = {8'hff, 8'd2,8'hfb,8'd4};

  #10
  $display("Time = %0d",$time);
  $display("Target = %h",{9'h1e0, 9'h19e, 9'd48, 9'd98});
  if (out == {9'h1e0, 9'h19e, 9'd48, 9'd98})
    $display("out = %h\n\t\t\tPASS!", out);
  else
    $display("out = %h\n\t\t\tFAIL!", out);

  // next values
  a = {8'h80, 8'd128,8'd200,8'd255};
  b = {8'd127, 8'd128,8'd200,8'd255};

  #10
  $display("Time = %0d",$time);
  $display("Target = %h",{9'h1ff, 9'h100, 9'h190, 9'h1fe});
  if (out == {9'h1ff, 9'h100, 9'h190, 9'h1fe})
    $display("out = %h\n\t\t\tPASS!", out);
  else
    $display("out = %h\n\t\t\tFAIL!", out);

  #80
  $display("\n");
  $stop;
end

endmodule
