`include "../network_params.h"
module mult_adder_ctrl(
  input clock,
  input reset,
  
  input buffer_rdy,

);

// wire declarations


// reg declarations


// x and y counters for window selectors
always@(posedge clock or negedge reset) begin
  if (reset == 1'b0) begin

  end else if(buffer_rdy) begin



  end else begin // buffer is not ready
    x_counter <= 



  end // reset
end // always
