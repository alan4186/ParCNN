`timescale 1 ps / 1 ps
module requantize_9bit_tb();

parameter SHIFT = 1;
parameter SIZE = 4;

reg clock;
reg reset;

reg [9*SIZE-1:0] in;

wire [8*SIZE-1:0] out_1;
wire [8*SIZE-1:0] out_2;

// DUT 1
requantize_9bit #(
  .SHIFT(SHIFT),
  .SIZE(SIZE)
)
dut_1 (
  .clock(clock),
  .reset(reset),
  .pixel_in(in),
  .pixel_out(out_1)
);

// DUT 2
requantize_9bit #(
  .SHIFT(-SHIFT),
  .SIZE(SIZE)
)
dut_2 (
  .clock(clock),
  .reset(reset),
  .pixel_in(in),
  .pixel_out(out_2)
);


always begin
  #5 clock <= ~clock;
end

initial begin
  $display("######################");
  $display("requantize_9bit_tb #");
  $display("######################");

  clock = 1'b1;
  reset = 1'b1;
  in = {9'd0, 9'h1ff, 9'd200, 9'h122};

  #10
  reset = 1'b0;

  #10
  reset = 1'b1;

  #10
  $display("Time = %0d",$time);
  if (out_1 == {8'd0, 8'hfe, 8'd127, 8'd128})
    $display("out = %h\n\t\t\tPASS!", out_1);
  else
    $display("out = %h\n\t\t\tFAIL!", out_1);
 
  if (out_2 == {8'd0, 8'hff, 8'd100, 8'h191})
    $display("out = %h\n\t\t\tPASS!", out_2);
  else
    $display("out = %h\n\t\t\tFAIL!", out_2);
 
  // Next input 
  in = {9'd127, 9'h180, 9'd16, 9'h158};

  #10
  $display("Time = %0d",$time);
  if (out_1 == {8'd127, 8'd128, 8'd32, 8'd128})
    $display("out = %h\n\t\t\tPASS!", out_1);
  else
    $display("out = %h\n\t\t\tFAIL!", out_1);

  if (out_2 == {8'd63, 8'hc0, 8'd8, 8'hac})
    $display("out = %h\n\t\t\tPASS!", out_2);
  else
    $display("out = %h\n\t\t\tFAIL!", out_2);


  #20
  $display("\n");
  $stop;
end

endmodule
