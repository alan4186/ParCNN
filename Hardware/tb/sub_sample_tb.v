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

// loop ints
//integer i;
integer j;

genvar i;
generate
	for(i=0; i < `NH_VECTOR_WIDTH; i=i+`NN_WIDTH) begin : nh_assignment
		assign element[i] = sub_in[i+`NN_BITWIDTH:i];
	end  
endgenerate


initial begin
  #20 reset = 1'b1;

  #20 reset = 1'b0;

  #20 
  reset = 1'b1;
  sub_in = $random;
  
  #10
  for(j=0; j < `NEIGHBORHOOD_SIZE; j=j+1) begin 
	  $display ("Element %d = %d", j, element[j]);
		tb_mean = tb_mean +element[j];
  end
	$display ("tb_mean %d sum = %d", j, tb_mean);
  tb_mean = tb_mean/`NEIGHBORHOOD_SIZE;
  $display ("tb_mean %d", tb_mean);	
  $display ("dut mean: %d", sub_out);

  if(tb_mean == sub_out) begin
    $display("PASS!");
  end else begin
    $display("FAIL!");
  end


 # 100
   $finish;
	
end
endmodule
