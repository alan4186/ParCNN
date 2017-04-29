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

wire [SIZE-1:0] c;
wire [8*SIZE-1:0] sum_8; // the 8 bit sum of the addition, only 7 msb needed

genvar i;
generate
for(i=0; i<SIZE; i=i+1) begin : bias_loop
  add_8bit_signed add_inst (
    .clock(clock),
    .dataa(a[i*8+7:i*8]),
    .datab(b[i*8+7:i*8]),
    .cout(c[i]),
    .result(sum_8[i*8+7:i*8])
  );
end //for

// wire up carry bit
for(i=0; i<SIZE; i=i+1) begin : carry_loop
  assign sum[i*9+8:i*9] = {c[i], sum_8[i*8+7:i*8]};
end // for

endgenerate

endmodule
