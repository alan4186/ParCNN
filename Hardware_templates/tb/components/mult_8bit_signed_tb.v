`timescale 1 ps / 1 ps
module mult_8bit_signed_tb();

reg clock;

reg [7:0] a;
reg [7:0] b;
wire [15:0] result;

// DUT
mult_8bit_signed dut (
  .clock(clock),
  .dataa(a),
  .datab(b),
  .result(result)
);

always begin
  #5 clock <= ~clock;
end

initial begin
  $display("#######################");
  $display("mult_8bit_signed_tb #");
  $display("#######################");

  clock = 1'b1;
  a = 8'hff;
  b = 8'hff;

  #10
  $display("Time = %0d",$time);
  if (result == 16'h0001 )
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  // Set the next input values
  a = 8'h01;
  b = 8'hff;

  #10
  $display("Time = %0d",$time);
  if (result == 16'hffff )
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  // Set the next input values
  a = 8'h80;
  b = 8'h80;

  #10
  $display("Time = %0d",$time);
  if (result == 16'h4000)
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  // Set the next input values
  a = 8'h25;
  b = 8'hbe;

  #10
  $display("Time = %0d",$time);
  if (result == 16'hf676)
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  #20
  $display("\n");
  $stop;
end

endmodule
