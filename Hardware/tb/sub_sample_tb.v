`include "../network_params.h"
module sub_sample_tb;
 reg clock;
 reg reset;
 reg [`NH_VECTOR_BITWIDTH:0] sub_in;
 wire [`NN_BITWIDTH:0] sub_out;
 wire [`NN_BITWIDTH:0] element[`NEIGHBORHOOD_SIZE];
 reg [`NN_BITWIDTH:0] tb_mean;

sub_sample dut(
  .clock(clock),
  .reset(reset),
  .rect_in(sub_in),
  .rect_out(sub_out)
);

initial begin
  clock = 1'b0;
  reset = 1'b0;
  sub_in = 1'b0;
  tb_mean = `NN_WIDTH'd0;
end

always 
  #5 clock = !clock;

initial begin
  #20 reset = 1'b1;

  #20 reset = 1'b0;

  #20 
  reset = 1'b1;
  sub_in = $random;

  #20 
  
  sub_in = $random;
  
	for(int i=0; i < `NH_VECTOR_WIDTH; i=i+`NN_WIDTH) begin
		element[i] = sub_in[i+`NN_BITWIDTH:i];
		$display ("Element %d = %d", i, element[i]);
	end  
  #10

  for(i=0; i < `NEIGHBORHOOD_SIZE; i=i+1) begin 
		tb_mean = tb_mean +element[i];
		$display ("tb_mean %d sum = %d", i, tb_mean);
  end
  
  #10
  
  tb_mean = tb_mean/`NEIGHBORHOOD_SIZE;
  $display ("tb_mean %d", tb_mean);	
 # 100
   $finish;
	
end
endmodule
