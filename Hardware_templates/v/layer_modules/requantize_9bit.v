module requantize_9bit #(
  parameter SHIFT,
  parameter SIZE
)(
  input clock,
  input reset,
  input [9*SIZE-1:0] pixel_in,
  output [8*SIZE-1:0] pixel_out
);

wire [32*SIZE-1:0] pixel_in32;

genvar i;
generate
for(i=0; i<SIZE; i=i+1) begin : assign_32
  assign pixel_in32[32*i+31:32*i] = { {23{pixel_in[9*i+8]}}, pixel_in[9*i+8:9*i] };
end // for
endgenerate

requantize_32bit #(
  .SHIFT(SHIFT),
  .SIZE(SIZE)
)
rq_32 (
  .clock(clock),
  .reset(reset),
  .pixel_in(pixel_in32),
  .pixel_out(pixel_out)
);

endmodule

