/* 
kernels:
  #1
  [1][1][2][2]
  [1][1][2][2]
  [2][2][1][1]
  [2][2][1][1]

  #2
  [-2][-2][3][3]
  [-2][-2][3][3]
  [-2][-2][3][3]
  [-2][-2][3][3]

windows:
  cycle 1:
  [15][14][13][12]
  [11][10][9] [8]
  [7] [6] [5] [4]
  [3] [2] [1] [0]

  cycle 2:
  [16][15][14][13]
  [12][11][10][9]
  [8] [7] [6] [5]
  [4] [3] [2] [1]


pixels_out:
             window 1  | window 2
                       | 
  kernel 1     180     |   20 
            -----------+----------
  kernel 2     204     |   28
                       |

*/

`timescale 1 ps / 1 ps
module dense_2D_tb();

parameter NUM_TREES = 2;
parameter P_SR_DEPTH = 4;
parameter NUM_SR_ROWS = 4;
parameter MA_TREE_SIZE = 16;

reg clock;
reg reset;

reg [7:0] pixel_in;

wire [8*NUM_TREES*MA_TREE_SIZE-1:0] kernel;

wire [32*NUM_TREES-1:0] pixel_out;

// assign kernels
// see comment at top for kernel or window orientation,
assign kernel = { 
/* kernel 2 */    8'd3, 8'd3, 8'hfe, 8'hfe,
                  8'd3, 8'd3, 8'hfe, 8'hfe,
                  8'd3, 8'd3, 8'hfe, 8'hfe,
                  8'd3, 8'd3, 8'hfe, 8'hfe,
/* kernel 1 */    8'd2, 8'd2, 8'd1, 8'd1,
                  8'd2, 8'd2, 8'd1, 8'd1,
                  8'd1, 8'd1, 8'd2, 8'd2,
                  8'd1, 8'd1, 8'd2, 8'd2
                };

// DUT
dense_2D #(
  .NUM_TREES(NUM_TREES),
  .P_SR_DEPTH(P_SR_DEPTH),
  .NUM_SR_ROWS(NUM_SR_ROWS),
  .MA_TREE_SIZE(MA_TREE_SIZE)
)
dut(
  .clock(clock),
  .reset(reset),
  .pixel_in(pixel_in),
  .kernel(kernel),
  .pixel_out(pixel_out)
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
  $display("###############");
  $display("dense_2D_tb #");
  $display("###############");

  clock = 1'b1;
  reset = 1'b1;
  
  #10 reset = 1'b0;
  #10 reset = 1'b1;

  #160 // wait 16 clock cycles for dense_sr 
  #50 // wait 5 clock cycles for mult_adder tree
  
  // check output

  $display("Time = %0d",$time);
  $display("Tree 1 pixel_out = %h", pixel_out[31:0]);
  if( pixel_out[31:0] == 32'd180) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else
  $display("Time = %0d",$time);
  $display("Tree 2 pixel_out = %h", pixel_out[63:32]);
  if( pixel_out[63:32] == 32'd20) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #10
  $display("Time = %0d",$time);
  $display("Tree 1 pixel_out = %h", pixel_out[31:0]);
  if( pixel_out[31:0] == 32'd204) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else
  $display("Time = %0d",$time);
  $display("Tree 2 pixel_out = %h", pixel_out[63:32]);
  if( pixel_out[63:32] == 32'd28) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else


  #100
  $display("\n");
  $stop;
end

endmodule
