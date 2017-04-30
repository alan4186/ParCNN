// This module adds 2 8 bit numbers and outputs a 9 bit number
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
