module parallel_out_sr #(
  parameter DEPTH = -1
)(
  input clock,
  input reset,
  
  input [7:0] shift_in,
  output [7:0] shift_out,

  output [8*DEPTH-1:0] p_out
);

// reg declarations
// wire declarations
wire [7:0] sr_wire [DEPTH:0];

// assign statments
assign sr_wire[0] = shift_in;
assign sr_wire[DEPTH] = shift_out;

genvar i;
generate
for(i=0; i<DEPTH; i=i+1) begin : parallel_out_sr_gen
  // instantiate shift register units
  sr_unit sr_unit_inst(
    .clock(clock),
    .reset(reset),
    .shift_in(sr_wire[i]),
    .shift_out(sr_wire[i+1])
  );
  // assign sr_wire to p_out
  assign p_out[i*8-1:i] = sr_wire[i+1];
end // for
endgenerate

endmodule

module sr_unit (
  input clock,
  input reset,
  input [7:0] shift_in,
  output reg [7:0] shift_out
);

always@(posedge clock or negedge reset) begin
  if(reset == 1'b0)
    shift_out <= 8'd0;
  else
    shift_out <= shift_in;
end // always

endmodule
