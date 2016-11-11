`include "../network_params.h"
module pipeline_tb();
reg clock;
reg reset;

reg [`SCREEN_X_BITWIDTH:0] screen_x;
reg [`SCREEN_Y_BITWIDTH:0] screen_y;

reg [`CAMERA_PIXEL_BITWIDTH:0] pixel;

wire [`RECT_OUT_BITWIDTH:0] rect1;
wire [`RECT_OUT_BITWIDTH:0] rect2;

// DUT
top top_inst(
  .clock(clock),
  .reset(reset),
  .screen_x_pos(screen_x),
  .screen_y_pos(screen_y),
  .test_pixel(pixel),
  .rect1(rect1),
  .rect2(rect2)
);

always begin
  #5 clock <= ~clock;
end

initial begin
  clock = 1'b0;
  reset = 1'b1;
  pixel = 9'b001000000; // 0.25
  
  #1000000 $stop;
end

always@(posedge clock) begin
  if(screen_x < 35) begin
    screen_x <= screen_x + 1;
  end else begin
    screen_x <= 0;
    if (screen_y < 35)
      screen_y <= screen_y+1;
    else 
      screen_y <= 0;
  end // reset
end // always

endmodule
