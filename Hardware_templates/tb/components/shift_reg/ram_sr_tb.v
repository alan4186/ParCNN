`timescale 1 ps / 1 ps
module ram_sr_tb();
parameter RAM_SR_DEPTH = 10;
parameter ROW_SHIFT = 3;

reg clock;
reg reset;

reg enable;
reg shift_row_up;
reg [7:0] column_shift_in;

wire [8*ROW_SHIFT-1:0] row_shift_in;

wire [7:0] column_shift_out;
wire [8*ROW_SHIFT-1:0] row_shift_out;

// DUT
ram_sr #(
  .RAM_SR_DEPTH(RAM_SR_DEPTH),
  .ROW_SHIFT(ROW_SHIFT)
)
dut(
  .clock(clock),
  .reset(reset),
  .enable(enable),
  .shift_row_up(shift_row_up),
  .column_shift_in(column_shift_in),
  .row_shift_in(row_shift_in),
  .column_shift_out(column_shift_out),
  .row_shift_out(row_shift_out)
);


// shift_in counter
always@(posedge clock or negedge reset) begin
  if(reset == 1'b0)
    column_shift_in <= 8'd0;
  else
    column_shift_in <= column_shift_in + 8'd1;
end

assign row_shift_in[7:0] = column_shift_in + 8'd2;
assign row_shift_in[15:8] = column_shift_in + 8'd1;
assign row_shift_in[23:16] = column_shift_in;


always begin
  #5 clock <= ~clock;
end

initial begin
  $display("#############");
  $display("ram_sr_tb #");
  $display("#############");
  clock = 1'b1;
  reset = 1'b1;

  enable = 1'b1;
  shift_row_up = 1'b0;

  #10 reset = 1'b0;
  #10 reset = 1'b1;

  #100 // check output
  $display("Time = %0d",$time);
  $display("column_shift_out = %h", column_shift_out);
  if( column_shift_out ==  8'd0) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  // Shift row
  shift_row_up = 1'b1;
  #10
  $display("Time = %0d",$time);
  $display("row_shift_out = %h", row_shift_out);
  if( row_shift_out ==  24'h030405) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  shift_row_up = 1'b0;
  enable = 1'b0;
  #40 // arbitrary wait
  enable =1'b1;
  $display("Time = %0d",$time);
  $display("row_shift_out = %h", row_shift_out);
  if( row_shift_out ==  24'h030405) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #10
  $display("Time = %0d",$time);
  $display("row_shift_out = %h", row_shift_out);
  if( row_shift_out ==  24'h040506) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #10
  $display("\n");
  $stop;
end

endmodule
