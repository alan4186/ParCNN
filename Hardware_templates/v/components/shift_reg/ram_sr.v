module ram_sr #(
  parameter RAM_SR_DEPTH = -1,
  parameter ROW_SHIFT = -1
)(
  input clock,
  input reset,
  input enable,
  input shift_row_up,
  input [7:0] column_shift_in,
  input [8*ROW_SHIFT-1:0] row_shift_in,
  output [7:0] column_shift_out,
  output [8*ROW_SHIFT-1:0] row_shift_out
);

wire [7:0] column_shift_in_wire [ROW_SHIFT-1:0];

reg [7:0] sr [RAM_SR_DEPTH-1:0];

assign column_shift_out = sr[RAM_SR_DEPTH-1];
assign column_shift_in_wire[0] = column_shift_in;

genvar i;
generate
for(i=1; i<ROW_SHIFT; i=i+1) begin : column_wire_loop
  // assign values to the colum_in wire to match the
  // row_shift_in wire length
  assign column_shift_in_wire[i] = sr[i-1];
end // for

for(i=0; i<ROW_SHIFT; i=i+1) begin : shift_in_loop
  always@(posedge clock) begin
    if (enable) begin
      if(shift_row_up) begin
        sr[i] <= row_shift_in[8*i+7:8*i];
      end else begin
        sr[i] <= column_shift_in_wire[i];
      end // shift_row_up
    end else begin
      sr[i] <= sr[i];
    end // enable if/else
  end // always
end // for

for(i=ROW_SHIFT; i<RAM_SR_DEPTH; i=i+1) begin : sr_loop
  always@(posedge clock) begin
    if (enable) begin
      if(shift_row_up) begin
        sr[i] <= sr[i-ROW_SHIFT];
      end else begin
        sr[i] <= sr[i-1];
      end // shift row up
    end else begin
      sr[i] <= sr[i];
    end // enable if/else
  end // always
end // for

// assign row_shift_out
for(i=0; i<ROW_SHIFT; i=i+1) begin : assign_row_shift_out
  assign row_shift_out[8*i+7:8*i] = sr[RAM_SR_DEPTH-ROW_SHIFT+i];
end // for

endgenerate

endmodule
