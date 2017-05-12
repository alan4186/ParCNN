/*
in->[0][1][2]->out
    \/ \/ \/
     p_out
*/
module parallel_out_sr #(
  parameter DEPTH = -1
)(
  input clock,
  input reset,

  input enable,
  input shift_row_up,
  input [7:0] column_shift_in,
  input [8*DEPTH-1:0] row_shift_in,

  output [7:0] shift_out,

  output [8*DEPTH-1:0] p_out
);

// reg declarations

// wire declarations
wire [7:0] sr_wire [DEPTH:0];

// assign statments
assign sr_wire[0] = column_shift_in;
assign shift_out = sr_wire[DEPTH];

genvar i;
generate

// instantiate shift register units
for(i=0; i<DEPTH; i=i+1) begin : parallel_out_sr_gen
  sr_unit sr_unit_inst(
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .shift_row_up(shift_row_up),
    .column_shift_in(sr_wire[i]),
    .row_shift_in(row_shift_in[8*i+7:8*i]),
    .shift_out(sr_wire[i+1])
  );
  // assign sr_wire to p_out
  assign p_out[i*8+7:i*8] = sr_wire[i+1];
end // for
endgenerate

endmodule

module sr_unit (
  input clock,
  input reset,
  input enable,
  input shift_row_up,
  input [7:0] column_shift_in,
  input [7:0] row_shift_in,
  output reg [7:0] shift_out
);

always@(posedge clock or negedge reset) begin
  if(reset == 1'b0)
    shift_out <= 8'd0;
  else if (enable) begin
    if (shift_row_up)
      shift_out <= row_shift_in;
    else
      shift_out <= column_shift_in;
  end else begin
    shift_out <= shift_out;
  end
end // always

endmodule
