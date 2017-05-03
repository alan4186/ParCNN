`timescale 1 ps / 1 ps
module add_8bit_signed_tb();

reg clock;

reg [8:0] a;
reg [8:0] b;
wire [8:0] result;

// DUT
add_8bit_signed dut (
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
  $display("add_8bit_signed_tb #");
  $display("######################");

  clock = 1'b1;
  a = 9'h1ff;
  b = 9'h1ff;

  #10
  $display("Time = %0d",$time);
  if (result == 9'h1fe )
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  // Set the next input values
  a = 9'h001;
  b = 9'h1ff;

  #10
  $display("Time = %0d",$time);
  if (result == 9'h000 )
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  // Set the next input values
  a = 9'h180;
  b = 9'h180;

  #10
  $display("Time = %0d",$time);
  if (result == 9'h100)
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  // Set the next input values
  a = 9'h025;
  b = 9'h1be;

  #10
  $display("Time = %0d",$time);
  if (result == 9'h1e3)
    $display("result = %0d\n\t\t\tPASS!", result);
  else
    $display("result = %0d\n\t\t\tFAIL!", result);

  #20
  $display("\n");
  $stop;
end

endmodule
