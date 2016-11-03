`include "../network_params.h"
module mult_adder_ctrl(
  input clock,
  input reset,
  
  input buffer_rdy,
  output [`X_COORD_BITWIDTH:0] x_coord,
  output [`Y_COORD_BITWIDTH:0] y_coord,

  output pixel_rdy // indicates valid data at end of tree/pipeline
);

// wire declarations

// reg declarations
reg rdy_shift_reg [`RDY_SHIFT_REG_SIZE];
reg [`X_COORD_BITWIDTH:0] x_counter;
reg [`Y_COORD_BITWIDTH:0] y_counter;


// assign statments
assign pixel_rdy = rdy_shift_reg[0];

assign x_coord = x_counter;
assign y_coord = y_counter;


// x and y counters for window selectors
always@(posedge clock or negedge reset) begin
  if (reset == 1'b0) begin
    x_counter <= `X_COORD_WIDTH'd0;
    y_counter <= `Y_COORD_WIDTH'd0;
  end else if(buffer_rdy) begin
    if(x_counter < `X_COORD_MAX) begin
      x_counter <= `X_COORD_WIDTH'd1;
      y_counter <= y_counter;
    end else begin
      x_counter <= `X_COORD_WIDTH'd0;
      if(y_counter < `Y_COORD_MAX)
        y_counter <= y_counter + `Y_COORD_WIDTH'd1;
      else
        y_counter <= `Y_COORD_WIDTH'd0;
    end
  end else begin // buffer is not ready
    x_counter <= `X_COORD_WIDTH'd0;
    y_counter <= `Y_COORD_WIDTH'd0;
  end // reset
end // always


// shift register to hold ready signal
genvar i;
generate
for (i=0; i < `RDY_SHIFT_REG_SIZE-1; i=i+1) begin : shift_reg_loop
  always@(posedge clock) begin
    rdy_shift_reg[i] <= rdy_shift_reg[i+1];
  end // always
end // for
endgenerate
// connect input to shift reg
always@(posedge clock) begin
  rdy_shift_reg[`RDY_SHIFT_REG_SIZE-1] <= buffer_rdy;
end

endmodule
