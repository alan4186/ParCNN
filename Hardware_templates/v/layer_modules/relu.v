module relu #(
  parameter MIN_MSB = -1, // the number of bits that must be compared
  parameter SIZE = -1
)(
  input clock,
  input reset,
  input [7:0] zero,
  input [8*SIZE-1:0] in,
  output [8*SIZE-1:0] out
);

genvar i;
for(i=0; i<SIZE; i=i+1) begin : relu_loop
  always@(posedge clock) begin
    if(in[i*8+7:(i*8)+8-MIN_MSB] > zero[7:8-MIN_MSB])
      out <= in;
    else
      out <= zero;
  end // always
end // for
endgenerate

endmodule
