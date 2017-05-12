`timescale 1 ps / 1 ps
module parallel_out_sr_tb();

parameter DEPTH = 3;

reg clock;
reg reset;

reg enable;
reg shift_row_up;
reg [7:0] column_shift_in;

wire [8*DEPTH-1:0] row_shift_in;

wire [7:0] shift_out;
wire [8*3-1:0] p_out;

// DUT
parallel_out_sr #(
  .DEPTH(DEPTH)
)
dut(
  .clock(clock),
  .reset(reset),
  .enable(enable),
  .shift_row_up(shift_row_up),
  .column_shift_in(column_shift_in),
  .row_shift_in(row_shift_in),
  .shift_out(shift_out),
  .p_out(p_out)
);


// shift_in counter
always@(posedge clock or negedge reset) begin
  if(reset == 1'b0)
    column_shift_in <= 8'd0;
  else
    column_shift_in <= column_shift_in + 8'd1;
end

// assign row_shift_in
assign row_shift_in[7:0] = column_shift_in + 8'd2;
assign row_shift_in[15:8] = column_shift_in + 8'd1;
assign row_shift_in[23:16] = column_shift_in;

always begin
  #5 clock <= ~clock;
end

initial begin
  $display("######################");
  $display("parallel_out_sr_tb #");
  $display("######################");
  clock = 1'b1;
  reset = 1'b1;

  enable = 1'b1;
  shift_row_up = 1'b0;

  #10 reset = 1'b0;
  #10 reset = 1'b1;

  #30 // check output
  $display("Time = %0d",$time);
  $display("p_out = %h", p_out);
  if( p_out == { 8'd0, 8'd1, 8'd2}) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else
  #10
  shift_row_up = 1'b1;
  #10
  $display("Time = %0d",$time);
  $display("p_out = %h", p_out);
  if( p_out == { 8'd4, 8'd5, 8'd6}) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #10
  enable = 1'b0;
  #40
  enable = 1'b1;
  // the out put with shift_row_up held high to keep counter in order
  $display("Time = %0d",$time);
  $display("p_out = %h", p_out);
  if( p_out == { 8'd5, 8'd6, 8'd7}) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else


  #30
  $display("\n");
  $stop;
end

endmodule
