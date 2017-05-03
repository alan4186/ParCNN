module mult_8bit_signed (
  input clock,
  input signed [7:0] dataa,
  input signed [7:0] datab,
  output reg signed [15:0] result
);

   always@(posedge clock) begin
	      result <= dataa * datab;
   end // always
endmodule
