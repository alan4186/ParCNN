`timescale 1 ps / 1 ps
module add_32bit_signed_tb();

reg clock;

reg [31:0] a;
reg [31:0] b;
wire [31:0] result;

// DUT
add_32bit_signed dut (
  .clock(clock),
  .dataa(a),
  .datab(b),
  .result(result)
);

always begin
  #5 clock <= ~clock;
end

initial begin
  $display("######################");
  $display("add_32bit_signed_tb #");
  $display("######################");

  clock = 1'b1;
  a = 32'hffffffff;
  b = 32'hffffffff;

  #10
  $display("Time = %0d",$time);
  if (result == 32'hfffffffe )
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  // Set the next input values
  a = 32'h00000001;
  b = 32'hffffffff;

  #10
  $display("Time = %0d",$time);
  if (result == 32'h00000000 )
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  // Set the next input values
  a = 32'h00000030;
  b = 32'h00000444;

  #10
  $display("Time = %0d",$time);
  if (result == 32'h00000474)
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  // Set the next input values
  a = 32'hffffffbe;
  b = 32'h00000025;

  #10
  $display("Time = %0d",$time);
  if (result == 32'hffffffe3)
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  #20
  $display("\n");
  $stop;
end

endmodule
