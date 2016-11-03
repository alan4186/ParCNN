module np_matrix_mult_ctrl(
  input clock,
  input reset,

  input buffer_rdy,

  output [`FFN_BITWIDTH:0] fm_addr,
  output [`WEIGHT_BITWIDTH:0] weight_addr,
);

always @(posedge clock or negedge reset) begin
  if (reset == 1'b0) begin
    fm_addr <= `FFN_WIDTH'd0;
    weight_addr <= `WEIGHT_WIDTH'd0;
  end else begin
    if (buffer_rdy) begin
      fm_addr <= fm_addr + `FFN_WIDTH'd1;
      weight_addr <= weight_add + `WEIGHT_WIDTH'd1;
    end else begin
      fm_addr <= `FFN_WIDTH'd0;
      weight_addr <= `WEIGHT_WIDTH'd0;
    end // rdy
  end // reset
end // always

endmodule
