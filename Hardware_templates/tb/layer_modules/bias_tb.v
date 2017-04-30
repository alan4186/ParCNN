`timescale 1 ps / 1 ps
module bias_tb();

parameter SIZE = 4;

reg clock;
reg reset;

reg [8*SIZE-1:0] a;
reg [8*SIZE-1:0] b;
wire [8*SIZE-1:0] out;

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
  if (out == {8'd1, 8'd2, 8'd3, 8'd4})
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);

  // next values
  a = {8'd31, 8'd28,8'd53,8'd94};
  b = {8'd1, 8'd2,8'd3,8'd4};

  #10
  $display("Time = %0d",$time);
  if (out == {8'd16, 8'd15, 8'd28, 8'd49})
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);

  // next values
  a = {8'd128, 8'd128,8'd200,8'd255};
  b = {8'd127, 8'd128,8'd200,8'd255};

  #10
  $display("Time = %0d",$time);
  if (out == {8'd127, 8'd128, 8'd200, 8'd255})
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);

  #80
  $display("\n");
  $stop;
end

endmodule
