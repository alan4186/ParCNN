`timescale 1 ps / 1 ps
module relu_tb();

parameter SIZE = 4;

reg clock;
reg reset;

reg [8*SIZE-1:0] in;

wire [8*SIZE-1:0] out;

// DUT
relu #(
  .SIZE(SIZE)
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
  $display("###########");
  $display("relu_tb #");
  $display("###########");
  clock = 1'b1;
  reset = 1'b1;
  in = {8'd255, 8'd128, 8'd64, 8'd32};

  #10
  reset = 1'b0;

  #10
  reset = 1'b1;

  #10
  $display("Time = %0d",$time);
  if (out == {8'd0, 8'd0, 8'd64, 8'd32})
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);

  // Set the next input values
  in = {8'hf0, 8'd33, 8'd1, 8'd0};

  #10
  $display("Time = %0d",$time);
  if (out == {8'd0, 8'd33, 8'd1, 8'd0})
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);

  #20
  $display("\n");
  $stop;
end

endmodule
