`include "../network_params.h"
module rect_linear(
  input clock,
  input reset,
  input [`NN_BITWIDTH:0] rect_in, 
  output reg [`NN_BITWIDTH:0] rect_out
		   );
   
   always@(posedge clock or negedge reset)begin
      if (reset == 1'b0) begin
	 rect_out <= `NN_WIDTH'd0;
      end else begin
	 if (rect_in[`NN_BITWIDTH]) begin
	    rect_out <= `NN_WIDTH'd0; 
	 end else begin
	    rect_out <= rect_in;
	 end
      end
   end
   
endmodule
