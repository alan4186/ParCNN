`include "../network_params.h"
module nh_shift_reg(
  input clock,
  input reset,
  
  input shift_in_rdy,
  input [`NH_BITWIDTH:0] shift_in,
  
  output dval,
  output [`NH_BITWIDTH:0] nh_max
);

// wire declarations
wire [`NH_BITWIDTH:0] shift_ins [`NH_DIM-1:0]; 
wire [(`NH_SIZE*2)-1:0] reg_valid;
wire [`NH_BITWIDTH:0] nh_row_max [`NH_DIM-1:0];

// reg declarations
reg [`NH_BITWIDTH:0] nh_reg [`NH_DIM-1:0][`NH_DIM-1:0];

// assign statments
assign dval = reg_valid[0];



// instantiate the shift registers to hold the current nh
genvar i;
genvar j;
generate 
for (j=0; j<`NH_DIM-1; j=j+1) begin : nh_row_loop
  for (i=0; i<`NH_DIM-1; i=i+1) begin : le_sr_inst 
    // assign dval signal to wire 
    assign reg_valid[(j*`NH_DIM+i)+`NH_SIZE] = nh_reg[i][j];
    // connect nh le's into shift reg
    always@(posedge clock or negedge reset) begin
      if(reset == 1'b0) begin
        nh_reg[i][j] <= `NH_WIDTH'd0;
      end else begin
        nh_reg[i][j] <= nh_reg[i+1][j];
      end // reset
    end // always
  end // for i
end // for j 
endgenerate


// instantiate shift register to buffer the part of the line not in nh
genvar k;
generate
for( k=0; k<`NH_DIM-1; i=i+1) begin : ram_sr_inst
  nh_sr_unit nh_sr_unit_inst(
    .clock(clock),
    .reset(reset),
    .shift_in({shift_in_rdy, nh_reg[`NH_DIM-1][k]}),
    .shift_out(nh_reg[0][k+1])
  );
end // for
endgenerate

// OR the data valid signals
genvar m;
generate
for (m=0; m<(`NH_SIZE*2)-1; m=m+1) begin: or_loop
  assign reg_valid[(m/2)-1] = reg_valid[m] | reg_valid[m-1];
end // for
endgenerate

// Find the Maximum in the NH
//////////////////////////////
// HARD CODED TO NH_DIM = 2 //
//////////////////////////////
assign nh_row_max[0] = (nh_reg[0][0] > nh_reg[0][1]) ? nh_reg[0][0] : nh_reg[0][1];
assign nh_row_max[1] = (nh_reg[1][0] > nh_reg[1][1]) ? nh_reg[1][0] : nh_reg[1][1];
assign nh_max = (nh_row_max[0] > nh_row_max[1]) ? nh_row_max[0] : nh_row_max[1];


module nh_sr_unit (
  input clock,
  input reset,
  input [`NH_BITWIDTH+1:0] shift_in,

  output reg [`NH_BITWIDTH+1:0] shift_out
);

always@(posedge clock or negedge reset) begin
  if(reset == 1'b0)
    shift_out <= {1'd0, `NH_WIDTH'd0};
  else
    shift_out <= shift_in;
end // always

endmodule
