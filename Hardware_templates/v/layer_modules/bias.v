/* Element wise addition of two signed 8 bit vectors
*
*  Element wise add two vectors of 2's compliment 8 bit numbers.  The output
*  is a singed vector of 9 bit numbers.  This module is used to add bias
*  values to the output of neural network layers.
*
*  The output latency of this module is 1 clock cycle.
* 
*  Paremeters:
*    SIZE: The number of 8 bit values in one input vector.
*
*  Inputs:
*    a: An input vector of signed 8 bit values
*    b: An input vector of signed 8 bit values
*
*  Outputs:
*    sum: The element wise addition of a and b in a singed 9 bit value
*
*/

module bias #(
  parameter SIZE = -1
)(
  input clock,
  input reset,
  input [8*SIZE-1:0] a,
  input [8*SIZE-1:0] b,
  output [9*SIZE-1:0] sum
);

genvar i;
generate
for(i=0; i<SIZE; i=i+1) begin : bias_loop
  add_8bit_signed add_inst (
    .clock(clock),
    .dataa({a[8*i+7], a[i*8+7:i*8]}), // extend sign bit for 9bit input
    .datab({b[8*i+7], b[i*8+7:i*8]}),
    .result(sum[i*9+8:i*9])
  );
end //for

endgenerate

endmodule
