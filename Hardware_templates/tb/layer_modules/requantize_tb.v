`timescale 1 ps / 1 ps
module relu_tb();

parameter SHIFT = 3;
parameter SIZE = 4;

reg clock;
reg reset;

reg [32*SIZE-1:0] in;

wire [8*SIZE-1:0] out_1;
wire [8*SIZE-1:0] out_2;

// DUT 1
requantize #(
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
requantize #(
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
  $display("#################");
  $display("requantize_tb #");
  $display("#################");

  clock = 1'b1;
  reset = 1'b1;
  in = {32'd0, 32'hffffffff, 32'd3150, 32'hffffeb38};

  #10
  reset = 1'b0;

  #10
  reset = 1'b1;

  #10
  $display("Time = %0d",$time);
  if (out == {8'd0, 8'hff, 8'd127, 8'd128})
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);
 
  // Next input 
  in = {32'd127, 32'd128, 32'd400 32'hfffffd58};

  #10
  $display("Time = %0d",$time);
  if (out == {8'd15, 8'hf0, 8'd50, 8'hab})
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);

  /*
  #10
  $display("Time = %0d",$time);
  if (out == {8'd255, 8'd128, 8'd64, 8'd44})
    $display("out = %0d\n\t\t\tPASS!", out);
  else
    $display("out = %0d\n\t\t\tFAIL!", out);
  */
  #20
  $display("\n");
  $stop;
end

endmodule
