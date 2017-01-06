// THIS IS A STANDIN FOR THE RAM SR MEGAFUCNTION
module ram_sr #(
  parameter DEPTH = -1
)(
  input clock,
  input reset,
  input [7:0] shift_in,
  output [7:0] shift_out
);

reg [7:0] sr [DEPTH-1:0];

assign shift_out = sr[DEPTH-1];

always@(posedge clock) begin
  sr[DEPTH-1:1] <= sr[DEPTH-2:0];
  sr[0] <= shift_in
end

endmodule
