/* Add two 8 bit 2's compliment inputs and output a 9 bit result
*
*  This module is used by the bias layer.
*/
module add_8bit_signed(
  input clock,
  input [8:0] dataa,
  input [8:0] datab,
  output reg [8:0] result
);
   always@(posedge clock) begin
	      //result <= {dataa[7], dataa} + {datab[7], datab};
	      result <= dataa + datab;
   end // always
   endmodule
