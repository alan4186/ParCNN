/* 8 bit rectified linear activation function
*
*  Apply the rectified linear activation function:
*    out = in, in >= 0
*    out = 0, in < 0
*
*  The input must be 2's compliment because only the MSB of the input is 
*  checked.
*
*  The SIZE parameter represents the number of relu activation units in the
*  layer.  One activation function is implemented for each input and all
*  activations are computed in parallel.  The inputs to the layer are
*  concatenated into a single port with 8*SIZE bits.  The output of the 
*  activations are concatenated in the same order as the input.  The output
*  is the same size as the input.
* 
*  The output latency of this module is 1 clock cycle.
*
*  Parameters:
*    SIZE: The number of activations units.
*
*  Inputs:
*    in: A signed vector of 8 bit values.
*
*  Outputs:
*    out: A signed vector of 8 bit values.  All outputs will be >= 0.
*
*/
module relu #(
  parameter MIN_MSB = -1, // the number of bits that must be compared
  parameter SIZE = -1
)(
  input clock,
  input reset,
  input [7:0] zero,
  input [8*SIZE-1:0] in,
  output reg [8*SIZE-1:0] out
);

genvar i;
generate
for(i=0; i<SIZE; i=i+1) begin : relu_loop
  always@(posedge clock) begin
    if(in[(i*8)+7:(i*8)+(8-MIN_MSB)] > zero[7:(8-MIN_MSB)])
      out[i*8+7:i*8] <= in[i*8+7:i*8];
    else
      out[i*8+7:i*8] <= zero;
  end // always
end // for
endgenerate

endmodule
