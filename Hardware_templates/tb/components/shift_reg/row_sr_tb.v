module row_sr_tb ();

parameter ROW_SR_DEPTH = 10;
parameter ROW_SHIFT = 3;

reg clock;
reg reset;

reg shift_in_enable;
reg shift_out_enable;
reg shift_row_up;
reg [7:0] shift_in;

wire row_shift_rdy;
wire full;
wire empty;
wire [7:0] shift_out;
wire [ROW_SHIFT*8-1:0] p_shift_out;


// DUT
row_sr #(
  .ROW_SR_DEPTH(ROW_SR_DEPTH),
  .ROW_SHIFT(ROW_SHIFT)
)
dut (
  .clock(clock),
  .reset(reset),
  .shift_in_enable(shift_in_enable),
  .shift_out_enable(shift_out_enable),
  .shift_row_up(shift_row_up),
  .shift_in(shift_in),
  .row_shift_rdy(row_shift_rdy),
  .full(full),
  .empty(empty),
  .shift_out(shift_out),
  .p_shift_out(p_shift_out)
);

always@(posedge clock or negedge reset) begin
  if(reset == 1'b0)
    shift_in <= 8'd0;
  else
    shift_in <= shift_in + 8'd1;
end // always



always begin
  #5 clock <= ~clock;
end

initial begin
  $display("#############");
  $display("row_sr_tb #");
  $display("#############");

  clock = 1'b0;
  reset = 1'b1;
  shift_in_enable = 1'b0;
  shift_out_enable = 1'b0;
  shift_row_up = 1'b0;

  #10
  reset = 1'b0;

  #10
  reset = 1'b1;

  shift_in_enable = 1'b1;

  #((ROW_SR_DEPTH - 1) * 10) // fill up all but one space
  // test full signal
  $display("Time = %0d",$time);
  $display("row_shift_rdy= %d", row_shift_rdy);
  $display("full = %d", full);
  $display("empty = %d", empty);
  $display("shift_out = %d", shift_out);
  $display("p+shift_out = %d, %d,%d",
    p_shift_out[23:16], p_shift_out[15:8], p_shift_out[7:0] );
  if( full ==  1'd0) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else


  #10 // fill up last space
  shift_in_enable = 1'b0;
  $display("Time = %0d",$time);
  $display("row_shift_rdy= %d", row_shift_rdy);
  $display("full = %d", full);
  $display("empty = %d", empty);
  $display("shift_out = %d", shift_out);
  $display("p+shift_out = %d, %d,%d",
    p_shift_out[23:16], p_shift_out[15:8], p_shift_out[7:0] );
  if( full ==  1'd1) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #20 // wait
  // test shift out
  shift_out_enable = 1'b1;
  $display("Time = %0d",$time);
  $display("row_shift_rdy= %d", row_shift_rdy);
  $display("full = %d", full);
  $display("empty = %d", empty);
  $display("shift_out = %d", shift_out);
  $display("p+shift_out = %d, %d,%d",
    p_shift_out[23:16], p_shift_out[15:8], p_shift_out[7:0] );
  if( shift_out ==  8'd0) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else
  #10
  // test row shift out
  shift_out_enable = 1'b0;
  shift_row_up = 1'b1;
  $display("Time = %0d",$time);
  $display("row_shift_rdy= %d", row_shift_rdy);
  $display("full = %d", full);
  $display("empty = %d", empty);
  $display("shift_out = %d", shift_out);
  $display("p+shift_out = %d, %d,%d",
    p_shift_out[23:16],p_shift_out[15:8], p_shift_out[7:0] );
  if( p_shift_out ==  {8'd4, 8'd3, 8'd2} ) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #10
  shift_row_up = 1'b1;
  $display("Time = %0d",$time);
  $display("row_shift_rdy= %d", row_shift_rdy);
  $display("full = %d", full);
  $display("empty = %d", empty);
  $display("shift_out = %d", shift_out);
  $display("empty = %d", empty);
  $display("p_shift_out = %d, %d,%d",
    p_shift_out[23:16],p_shift_out[15:8], p_shift_out[7:0] );
  if( p_shift_out ==  {8'd7, 8'd6, 8'd5} ) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else
  #10
  // test row shift rdy
  shift_out_enable = 1'b1;
  shift_row_up = 1'b0;
  #20 // remove 2 more from queue.  2 should be left
  $display("Time = %0d",$time);
  $display("row_shift_rdy= %d", row_shift_rdy);
  $display("full = %d", full);
  $display("empty = %d", empty);
  $display("shift_out = %d", shift_out);
  $display("p+shift_out = %d, %d,%d",
    p_shift_out[23:16], p_shift_out[15:8], p_shift_out[7:0] );
  if( row_shift_rdy == 1'b0) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #20 // remove 2 more from queue.  Queue should be empty
  $display("Time = %0d",$time);
  $display("row_shift_rdy= %d", row_shift_rdy);
  $display("full = %d", full);
  $display("empty = %d", empty);
  $display("shift_out = %d", shift_out);
  $display("p+shift_out = %d, %d,%d",
    p_shift_out[23:16], p_shift_out[15:8], p_shift_out[7:0] );
  if( empty == 1'b1) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #10
  shift_in_enable = 1'b1;
  // test simultanious read and write
  $display("Time = %0d",$time);
  $display("row_shift_rdy= %d", row_shift_rdy);
  $display("full = %d", full);
  $display("empty = %d", empty);
  $display("shift_out = %d", shift_out);
  $display("p+shift_out = %d, %d,%d",
    p_shift_out[23:16], p_shift_out[15:8], p_shift_out[7:0] );
  if( empty == 1'b0 && p_shift_out == 8'd20 ) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #10
  $stop;

end

endmodule
