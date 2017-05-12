`timescale 1 ps / 1 ps
module convolution_sr_tb();

parameter P_SR_DEPTH = 3;
parameter RAM_SR_DEPTH = 4;
parameter NUM_SR_ROWS = 3;

reg clock;
reg reset;

reg enable;
reg shift_row_up;
reg [7:0] column_shift_in;
wire [8*P_SR_DEPTH-1:0] row_shift_in;

wire [8*P_SR_DEPTH*NUM_SR_ROWS-1:0] window_out;

// DUT
convolution_sr #(
  .P_SR_DEPTH(P_SR_DEPTH),
  .RAM_SR_DEPTH(RAM_SR_DEPTH),
  .NUM_SR_ROWS(NUM_SR_ROWS)
)
dut(
  .clock(clock),
  .reset(reset),
  .enable(enable),
  .shift_row_up(shift_row_up),
  .column_shift_in(column_shift_in),
  .row_shift_in(row_shift_in),
  .p_window_out(window_out)
);


// shift_in counter
always@(posedge clock or negedge reset) begin
  if(reset == 1'b0)
    column_shift_in <= 8'd0;
  else if(enable)
    column_shift_in <= column_shift_in + 8'd1;
  else
    column_shift_in <= column_shift_in;
end

assign row_shift_in[7:0] = column_shift_in + 8'd2;
assign row_shift_in[15:8] = column_shift_in + 8'd1;
assign row_shift_in[23:16] = column_shift_in;

always begin
  #5 clock <= ~clock;
end

initial begin
  $display("####################");
  $display("convolution_sr_tb#");
  $display("####################");

  clock = 1'b1;
  reset = 1'b1;

  enable = 1'b1;
  shift_row_up = 1'b0;

  #10 reset = 1'b0;
  #10 reset = 1'b1;

  #170 // check output
  $display("Time = %0d",$time);
  $display("window_out =\n%h\n", window_out[23:0]);
  $display("%h\n", window_out[47:24]);
  $display("%h\n", window_out[71:48]);
  if( window_out[23:0] == { 8'd14, 8'd15, 8'd16 } &
      window_out[47:24] == { 8'd7, 8'd8, 8'd9 } &
      window_out[71:48] == { 8'd0, 8'd1, 8'd2 }
    ) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #20
  $display("Time = %0d",$time);
  $display("window_out =\n%h\n", window_out[23:0]);
  $display("%h\n", window_out[47:24]);
  $display("%h\n", window_out[71:48]);
  if( window_out[23:0] == { 8'd16, 8'd17, 8'd18 } &
      window_out[47:24] == { 8'd9, 8'd10, 8'd11 } &
      window_out[71:48] == { 8'd2, 8'd3, 8'd4 }
    ) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #10
  enable = 1'b0;
  #40
  enable = 1'b1;
  $display("Time = %0d",$time);
  $display("window_out =\n%h\n", window_out[23:0]);
  $display("%h\n", window_out[47:24]);
  $display("%h\n", window_out[71:48]);
  if( window_out[23:0] == { 8'd17, 8'd18, 8'd19 } &
      window_out[47:24] == { 8'd10, 8'd11, 8'd12 } &
      window_out[71:48] == { 8'd3, 8'd4, 8'd5 }
    ) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else


  #20
  shift_row_up = 1'b1;
  #10
  $display("Time = %0d",$time);
  $display("window_out =\n%h\n", window_out[23:0]);
  $display("%h\n", window_out[47:24]);
  $display("%h\n", window_out[71:48]);
  if( window_out[23:0] == { 8'd22, 8'd23, 8'd24 } &
      window_out[47:24] == { 8'd15, 8'd16, 8'd17 } &
      window_out[71:48] == { 8'd8, 8'd9, 8'd10 }
    ) begin
    $display("\t\t\tPASS!");
  end else begin
    $display("\t\t\tFAIL!");
  end // end if/else

  #100
  $display("\n");
  $stop;
end

endmodule
