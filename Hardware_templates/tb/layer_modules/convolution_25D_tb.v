/* 
kernels:
  #1
      /[3][3][3][3]
     / [3][3][3][3]
    /  [3][3][3][3]
   /   [3][3][3][3] z_dim = 1
  /               / 
  [1][1][2][2]   /
  [1][1][2][2]  /
  [2][2][1][1] /
  [2][2][1][1]/  z_dim = 0

  #2
      /[4][4][4][4]
     / [4][4][4][4]
    /  [4][4][4][4]
   /   [4][4][4][4]
  /               / 
  [2][2][3][3]   /
  [2][2][3][3]  /
  [2][2][3][3] /
  [2][2][3][3]/

windows:
  cycle 1:
      /[21][20][19][18]
     / [15][14][13][12]
    /  [9 ][8 ][7 ][6 ]
   /   [3 ][2 ][1 ][0 ]
  /                   /
  [21][20][19][18]   /
  [15][14][13][12]  /
  [9 ][8 ][7 ][6 ] /
  [3 ][2 ][1 ][0 ]/


  cycle 2:
      /[22][21][20][19]
     / [16][15][14][13]
    /  [10][9 ][8 ][7 ]
   /   [4 ][3 ][2 ][1 ]
  /                   /
  [22][21][20][19]   /
  [16][15][14][13]  /
  [10][9 ][8 ][7 ] /
  [4 ][3 ][2 ][1 ]/


pixels_out:
             window 1  | window 2
                       | 
  kernel 1     756     |   828
            -----------+----------
  kernel 2     1084    |   1188
                       |

*/

`timescale 1 ps / 1 ps
module convolution_25D_tb();

parameter NUM_TREES = 2;
parameter Z_DEPTH = 2;
parameter P_SR_DEPTH = 4;
parameter RAM_SR_DEPTH = 2;
parameter NUM_SR_ROWS = 4;
parameter MA_TREE_SIZE = 16;

reg clock;
reg reset;

reg [7:0] pixel_in;

wire [8*NUM_TREES*MA_TREE_SIZE*Z_DEPTH-1:0] kernel;

wire [32*NUM_TREES-1:0] pixel_out;

// assign kernels
// see comment at top for kernel or window orientation,
assign kernel = { 
/* kernel 2 z=1 */ 8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
/* kernel 2 z=0 */ 8'd3, 8'd3, 8'd2, 8'd2,
                   8'd3, 8'd3, 8'd2, 8'd2,
                   8'd3, 8'd3, 8'd2, 8'd2,
                   8'd3, 8'd3, 8'd2, 8'd2,
/* kernel 1 z=1 */ 8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
/* kernel 1 z=0 */ 8'd2, 8'd2, 8'd1, 8'd1,
                   8'd2, 8'd2, 8'd1, 8'd1,
                   8'd1, 8'd1, 8'd2, 8'd2,
                   8'd1, 8'd1, 8'd2, 8'd2
                };

// DUT
convolution_25D #(
  .NUM_TREES(NUM_TREES),
  .Z_DEPTH(Z_DEPTH),
  .P_SR_DEPTH(P_SR_DEPTH),
  .RAM_SR_DEPTH(RAM_SR_DEPTH),
  .NUM_SR_ROWS(NUM_SR_ROWS),
  .MA_TREE_SIZE(MA_TREE_SIZE)
)
dut(
  .clock(clock),
  .reset(reset),
  .pixel_vector_in({pixel_in, pixel_in}),
  .kernel(kernel),
  .pixel_vector_out(pixel_out)
);


// pixel_in counter
always@(posedge clock or negedge reset) begin
  if(reset == 1'b0) 
    pixel_in <= 8'd0;
  else
    pixel_in <= pixel_in + 8'd1;
end

always begin
  #5 clock <= ~clock;
end

initial begin
  clock = 1'b1;
  reset = 1'b1;
  
  #10 reset = 1'b0;
  #10 reset = 1'b1;

  #220 // wait 22 clock cycles for layer_sr 
  #50 // wait 5 clock cycles for mult_adder tree
  
  // check output

  $display($time);
  $display("Tree 1 pixel_out = %h", pixel_out);
  if( pixel_out[31:0] == 32'd252) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else
  $display($time);
  $display("Tree 2 pixel_out = %h", pixel_out);
  if( pixel_out[63:32] == 32'd412) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else

  #10
  $display($time);
  $display("Tree 1 pixel_out = %h", pixel_out);
  if( pixel_out[31:0] == 32'd276) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else
  $display($time);
  $display("Tree 2 pixel_out = %h", pixel_out);
  if( pixel_out[63:32] == 32'd452) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else


  #500
  $stop;
end

endmodule
