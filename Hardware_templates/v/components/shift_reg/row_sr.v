/* This module implements the row shift register that buffers a row of the
*  convolution window to feed in parallel to the first row of the window.
*  This module is implemented as a FIFO with a wider output port than input
*  port.
*/
module row_sr #(
  parameter ROW_SR_DEPTH = -1,
  parameter ROW_SHIFT = -1
)(
  input clock,
  input reset,

  input shift_in_enable,
  input shift_out_enable,
  input shift_row_up, // shift_out_enable must be high to shift row up
  input [7:0] shift_in,

  output row_shift_rdy,
  output full,
  output empty,
  output reg [7:0] shift_out,
  output [ROW_SHIFT*8-1:0] p_shift_out
);

reg [7:0] buffer [ROW_SR_DEPTH-1:0];

reg [15:0] wr_pointer;
reg [15:0] rd_pointer;
reg [15:0] counter;

wire [15:0] p_rd_pointer [ROW_SHIFT-1:0];

assign full = (counter == ROW_SR_DEPTH) ? 1'b1 : 1'b0;
assign empty = (counter == 16'd0) ? 1'b1: 1'b0;
assign row_shift_rdy = (counter > ROW_SHIFT) ? 1'b1 : 1'b0;


always@(posedge clock or negedge reset) begin
  if (reset == 1'b0) begin
    wr_pointer <= 16'd0;
    rd_pointer <= 16'd0;
  end else begin

    // write pointer
    if(shift_in_enable == 1'b1)
      if (wr_pointer == ROW_SR_DEPTH-1)
        wr_pointer <= 16'd0;
      else
        wr_pointer <= wr_pointer + 16'd1;

    // read pointer
    if(shift_out_enable == 1'b1)
      if(shift_row_up == 1'b1) // shift row out
        if(rd_pointer < ROW_SR_DEPTH - ROW_SHIFT - 1)
          //rd_pointer <= rd_pointer + 16'd1;
          rd_pointer <= rd_pointer + ROW_SHIFT;
        else
          rd_pointer <= rd_pointer + ROW_SHIFT - ROW_SR_DEPTH;
      else // shift 1 out
        if(rd_pointer == ROW_SR_DEPTH-1)
          rd_pointer <= 16'd0;
        else
          rd_pointer <= rd_pointer + 16'd1;
  end // reset
end // always

always@(posedge clock) begin
  shift_out <= buffer[rd_pointer];
end

integer i;
genvar j;
generate
for(j=0; j<ROW_SHIFT; j=j+1) begin : p_shift_out_loop
  //assign p_rd_pointer[j] = (rd_pointer < ROW_SR_DEPTH - ROW_SHIFT - 1 - j) ?
  assign p_rd_pointer[j] = (rd_pointer < ROW_SR_DEPTH - j ) ?
    rd_pointer + j : rd_pointer - ROW_SR_DEPTH + j;
  assign p_shift_out[8*j+7:8*j] = buffer[p_rd_pointer[j]];
end // for
endgenerate



always@(posedge clock or negedge reset) begin
  if (reset == 1'b0) begin
    for (i=0; i<ROW_SR_DEPTH; i=i+1) buffer[i] <= 8'd0;
  end else if(shift_in_enable == 1'b1)
    buffer[wr_pointer] <= shift_in;
end // always

always@(posedge clock or negedge reset) begin
  if (reset == 1'b0) begin
    counter <= 16'd0;
  end else if (shift_in_enable == 1'b1) begin
    if (shift_row_up == 1'b1) begin
      counter <= counter - ROW_SHIFT + 16'd1;
    end else if ( shift_out_enable == 1'b1) begin
      counter <= counter;
    end else begin
      counter <= counter + 16'd1;
    end
  end else begin
    if (shift_row_up == 1'b1) begin
      counter <= counter - ROW_SHIFT;
    end else if ( shift_out_enable == 1'b1) begin
      counter <= counter - 16'd1;
    end else begin
      counter <= counter;
    end
  end
end // always

endmodule
