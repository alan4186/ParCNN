//  A shifting buffer to buffer the input image.  The buffer should be 28x28
//  registers to hold the entire image and the buffer should be the size of
//  the kernel (9x9) to input part of the image into the mult-adder tree.

// buffer wire[0][0] is in the bottom right corner of image so that the video
// stream can be fed directly into buffer.  buffer_wire[max][max] is the top
// left corner.
 
`include "../network_params.h"
module shifting_buffer(
  input clock,
  input reset,
  input [`PIXEL_BITWIDHT:0] in,
  output [`BUFFER_OUT_VECTOR_BITWIDTH:0] buffer_out 
);

// paremeters


// wire declarations
wire [`PIXEL_WIDTH] buffer_wire [`BUFFER_BW:0][`BUFFER_BH:0]

// reg declarations


  genvar i
  genvar j
  generate
    for(j=1;j < `BUFFER_H; j=j+1) begin
      for(i=1; i < `BUFFER_W; i=i+1) begin
        buffer_unit unit_inst(
          .clock(clock),
          .reset(reset),
          .shift_en(shift_en),
          .shift_dir(shift_dir),
          .in_a(buffer_wire[i-1][j]), // right to left (width)
          .in_b(buffer_wire[i][j-1]), // bottom to top (height)
          .out(buffer_wire[i][j])
        );
      end
    end
  endgenerate

  // loop over first row of width and height
  genvar k;
  generate 
  for (k = 1; k < BUFFER_W; k=k+1) begin : width_row0_loop
    buffer_unit w_row0_unit_inst(
      .clock(clock),
      .reset(reset),
      .shift_en(shift_en),
      .shift_dir(shift_dir),
      .in_a(buffer_wire[k-1][0]), // right to left (width)
      .in_b(`CAMERA_PIXEL_WIDTH'd0), // bottom to top (height)
      .out(buffer_wire[k][0])
    );
  end // for

  for (k = 1; k < BUFFER_H; k=k+1) begin : height_row0_loop
    buffer_unit h_row0_unit_inst(
      .clock(clock),
      .reset(reset),
      .shift_en(shift_en),
      .shift_dir(shift_dir),
      .in_a(`CAMERA_PIXEL_WIDTH'd0), // right to left (width)
      .in_b(buffer_wire[0][k-1]), // bottom to top (height)
      .out(buffer_wire[0][k])
    );
  end // for 
  endgenerate

  // instantiate origin window unit
  buffer_unit origin_unit_inst(
      .clock(clock),
      .reset(reset),
      .shift_en(shift_en),
      .shift_dir(shift_dir),
      .in_a(pixel_in), // right to left (width)
      .in_b(`CAMERA_PIXEL_WIDTH'd0), // bottom to top (height)
      .out(buffer_wire[1][0])
    );
  end // for 
 



  // loop to connect buffer out vector to buffer_wire
  genvar n;
  genvar m;
  generate
    for (n=0; n < `BUFFER_H; n=n+1) begin : buffer_height_loop
      for (m=0; m < `BUFFER_W; m=m+1) begin : buffer_width_loop
        assign buffer_wire[m][n] = buffer_out[ \ 
        (`CAMERA_PIXEL_WIDTH*m)+(`BUFFER_W*CAMERA_PIXEL_WIDTH*n) +`CAMERA_PIXEL_BITWIDTH:\
          (`CAMERA_PIXEL_WIDTH*m)+(`BUFFER_W*CAMERA_PIXEL_WIDTH*n) \ 
          ];
  endmodule
  
  
  module buffer_unit(
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
