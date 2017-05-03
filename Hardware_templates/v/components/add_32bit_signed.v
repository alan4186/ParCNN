module add_32bit_signed(
  input clock,
  input [31:0] dataa,
  input [31:0] datab,
  output reg [31:0] result
);
   always@(posedge clock) begin
	      result <= dataa + datab;
   end // always
   endmodule
