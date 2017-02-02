`timescale 1 ps / 1 ps
module layer_sr_tb();

parameter P_SR_DEPTH = 3;
parameter RAM_SR_DEPTH = 4;
parameter NUM_SR_ROWS = 3;

reg clock;
reg reset;

reg [7:0] shift_in;

wire [8*P_SR_DEPTH*NUM_SR_ROWS-1:0] window_out;

// DUT
layer_sr #(
  .P_SR_DEPTH(P_SR_DEPTH),
  .RAM_SR_DEPTH(RAM_SR_DEPTH),
  .NUM_SR_ROWS(NUM_SR_ROWS)
)
dut(
  .clock(clock),
  .reset(reset),
  .shift_in(shift_in),
  .p_window_out(window_out)
);


// shift_in counter
always@(posedge clock or negedge reset) begin
  if(reset == 1'b0) 
    shift_in <= 8'd0;
  else
    shift_in <= shift_in + 8'd1;
end

always begin
  #5 clock <= ~clock;
end

initial begin
  clock = 1'b1;
  reset = 1'b1;
  
  #10 reset = 1'b0;
  #10 reset = 1'b1;

  #170 // check output
  $display($time);
  $display("window_out =\n%h\n", window_out[23:0]);
  $display("%h\n", window_out[47:24]);
  $display("%h\n", window_out[71:48]);
  if( window_out[23:0] == { 8'd14, 8'd15, 8'd16 } &
      window_out[47:24] == { 8'd7, 8'd8, 8'd9 } &
      window_out[71:48] == { 8'd0, 8'd1, 8'd2 }
    ) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else

  #20
  $display($time);
  $display("window_out =\n%h\n", window_out[23:0]);
  $display("%h\n", window_out[47:24]);
  $display("%h\n", window_out[71:48]);
  if( window_out[23:0] == { 8'd16, 8'd17, 8'd18 } &
      window_out[47:24] == { 8'd9, 8'd10, 8'd11 } &
      window_out[71:48] == { 8'd2, 8'd3, 8'd4 }
    ) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else


  #100
  $stop;
end

endmodule
