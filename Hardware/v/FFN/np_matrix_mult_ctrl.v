`include "../../network_params.h"
module np_matrix_mult_ctrl(
  input clock,
  input reset,

  input buffer_rdy,
  
  output reg [`FM_ADDR_BITWIDTH:0] addr,
  output reg product_rdy
);

always @(posedge clock or negedge reset) begin
  if (reset == 1'b0) begin
    addr <= `FM_ADDR_WIDTH'd0;
  end else begin
    if (buffer_rdy) begin
      addr <= addr + `FM_ADDR_WIDTH'd1;
    end else begin
      addr <= `FM_ADDR_WIDTH'd0;
    end // rdy
  end // reset
end // always


always@(posedge clock or negedge reset) begin
  if(reset == 1'b0) begin
    product_rdy <= 1'b0;
  end else begin
    if(addr == `ADDR_MAX) begin
      product_rdy <= 1'b1;
    end else begin
      product_rdy <= 1'b0;
    end // addr max
  end // reset
end // always

endmodule
