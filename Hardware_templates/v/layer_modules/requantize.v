module requantize #(
  parameter SHIFT,
  parameter SIZE
)(
  input clock,
  input reset,
  input [32*SIZE-1:0] pixel_in,
  output reg [8*SIZE-1:0] pixel_out
);

wire [24:0] ones;
wire [24:0] zeros;

// the +1 is for the MSB of q8,
// it is needed to make sure the sign bit 
// did not change
wire [24:0] remainder [SIZE-1:0];
wire [7:0] q8 [SIZE-1:0];

wire signed [31:0] left [SIZE-1:0];
wire signed [31:0] right [SIZE-1:0];
wire signed [31:0] pixel_in_s [SIZE-1:0];
wire signed [31:0] pixel_out_s [SIZE-1:0];

wire [7:0] q8_clipped [SIZE-1:0];

assign ones = {25{1'b1}};
assign zeros = {25{1'b0}};



genvar i;
generate
for(i=0; i<SIZE; i=i+1) begin : rq_loop
  assign pixel_in_s[i] = pixel_in[32*i+31:32*i];
  
  // Compute left and right shifts, both will be simulated but only one will
  // be synthesized because the constant parameter in the conditional will
  // mean unused shift is never latched
  assign left[i] = pixel_in_s[i] <<< SHIFT;
  assign right[i] = pixel_in_s[i] >>> (-1*SHIFT);
  assign pixel_out_s[i] = (SHIFT>0) ? left[i] : right[i];

  assign q8[i] = pixel_out_s[i][7:0];

  // add the sign bit to the remainder to make sure it has not changed
  assign remainder[i] = {pixel_out_s[i][31:8], q8[i][7]};
  
  // The value of the output if there is overflow
  assign q8_clipped[i] = pixel_in_s[i][31] ? 8'h80 : 8'h7f;

  always@(posedge clock) begin
    if(remainder[i] == ones | remainder[i] == zeros) begin
      pixel_out[8*i+7:8*i] <= q8[i];
    end else begin
      pixel_out[8*i+7:8*i] <= q8_clipped[i];
    end
  end //always
end // for

endgenerate

endmodule

