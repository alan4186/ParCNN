// define statments
`define WINDOW_W 9
`define WINDOW_BW WINDOW_W - 1 
`define WINDOW_H 9
`define WINDOW_BH WINDOW_H - 1 
`define PIXEL_WIDTH 30
`define PIXEL_BITWIDTH PIXEL_WIDHT - 1

module shifting_window(
  input clock,
  input reset,
  input [PIXEL_BITWIDHT:0] in,
  output [`PIXEL_WIDTH] window_wire [`WINDOW_BW:0][`WINDOW_BH:0]
);

// paremeters


// wire declarations
//  wire [`PIXEL_WIDTH] window_wire [`WINDOW_BW:0][`WINDOW_BH:0]

// reg declarations

  genvar i
  genvar j
  generate
    for(i=1;i < `WINDOW_W; i=i+1) begin
      for(j=1; j < `WINDOW_H; j=j+1) begin
        window_unit unit_inst(
          .clock(clock),
          .reset(reset),
          .shift_en(shift_en),
          .shift_dir(shift_dir),
          .in_a(window_wire[i-1][j]), // left to right
          .in_b(window_wire[i][j-1]), // top to bottom
          .out(window_wire[i][j])
        );
      end
    end
  endgenerate

  endmodule
  
  
  module window_unit(
    input clock,
    input reset,
    input shift_en,
    input shift_dir,
    input [`PIXEL_BITWIDTH:0] in_a,
    input [`PIXEL_BITWIDTH:0] in_b,
    output [`PIXEL_BITWIDTH:0] out
  );
    always@(posedge clock or negedge reset) begin
      if(reset == 1'b0)
        out <= `PIXEL_WIDTH'd0;
      else if(shift_en) begin
        if(shift_mode)
          out <= in_a;
        else
          out <= in_b;
      end else 
        out <= out;
    end // always
  endmodule
