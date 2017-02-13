// This module adds 2 8 bit numbers and requantizes the
// result to 8 bits.  So the range of the output is double
// the range of the input.  The range must be centered at Zero
module bias #(
  parameter SIZE = -1
)(
  input clock,
  input reset,
  input [8*SIZE-1:0] a,
  input [8*SIZE-1:0] b,
  output [8*SIZE-1:0] sum
);

reg [SIZE-1:0] c;

wire [8*SIZE-1:0] sum_8; // the 8 bit sum of the addition, only 7 msb needed

genvar i;
for(i=0; i<SIZE; i=i+1) begin : bias_loop
  add_8bit_unsign add_inst (
    .clock(clock),
    .dataa(a[i*8+7:i*8]),
    .datab(b[i*8+7:i*8]),
    .result(sum_8[i*8+7:i*8]),
    .carry(c[i])
  );
end //for

// wire up carry bit
for(i=0; i<SIZE; i=i+1) begin : carry_loop
  assign sum[i*8+7:i*8] = {c[i], sum[i*8+7:i*8+1]};
end // for



 /* 
  // check for overflow 
  always@(posedge clock) begin
    if(v[i])
      sum[i*8+7:i*8] <= 8'd255;
    else
      sum[i*8+7:i*8] <= sum_v[i*8+7:i*8];
  end // always
end // for
*/
endgenerate

endmodule
