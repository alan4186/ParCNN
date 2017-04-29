module requantize #(
  parameter SHIFT,
  parameter SIZE
)(
  input clock,
  input reset,
  input [32*SIZE-1:0] pixel_in,
  output reg [8*SIZE-1:0] pixel_out
);

wire [32-8+SHIFT:0] ones;
wire [32-8+SHIFT:0] zeros;

wire [32-8+SHIFT:0] remainder [SIZE-1:0];
wire [7:0] q8 [SIZE-1:0];

reg [7:0] q8_clipped [SIZE-1:0];

assign ones = (32+8+SHIFT){1'b1};
assign zeros = (32+8+SHIFT){1'b0};


genvar i;
generate
for(i=0; i<SIZE; i=i+1) begin : rq_loop
  always@(*) begin
    if( SHIFT > 0 ) begin
      {remainder[i], q8[i]} = pixel_in[i] << SHIFT;
    end else begin
      {remainder[i], q8[i]} = pixel_in[i][31:0-SHIFT];
    end

    if(remainder[i][32-8+SHIFT]) begin
      q8_clipped[i] = 8'd128; // -128 in 2's compliment
    end else begin
      q8_clipped[i] = 8'd127;
    end

  end // always

  always@(posedge clk) begin
    if(remainder[i] == ones | remainer[i] == zeros) begin
      pixel_out[i] <= q8[i];
    end else begin
      pixel_out[i] <= q8_clipped[i];
    end
  end //always
end // for
endgenerate
endmodule

