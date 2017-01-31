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
  sr[0] <= shift_in;
end

genvar i;
generate
for(i=0; i<DEPTH-1; i=i+1) begin : sr_loop
  always@(posedge clock) begin
    sr[i+1] <= sr[i];
  end
end
endgenerate

endmodule
