`timescale 1 ps / 1 ps
module dense_sr_tb();

parameter P_SR_DEPTH = 3;
parameter NUM_SR_ROWS = 3;

reg clock;
reg reset;

reg [7:0] shift_in;

wire [8*P_SR_DEPTH*NUM_SR_ROWS-1:0] window_out;

// DUT
dense_sr #(
  .P_SR_DEPTH(P_SR_DEPTH),
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
  $display("###############");
  $display("dense_sr_tb #");
  $display("###############");
  clock = 1'b1;
  reset = 1'b1;
  
  #10 reset = 1'b0;
  #10 reset = 1'b1;

  #90 // check output
  $display("Time = %0d",$time);
  $display("window_out =\n%h\n", window_out[23:0]);
  $display("%h\n", window_out[47:24]);
  $display("%h\n", window_out[71:48]);
  if( window_out[23:0] == { 8'd6, 8'd7, 8'd8 } &
      window_out[47:24] == { 8'd3, 8'd4, 8'd5 } &
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
  if( window_out[23:0] == { 8'd8, 8'd9, 8'd10 } &
      window_out[47:24] == { 8'd5, 8'd6, 8'd7 } &
      window_out[71:48] == { 8'd2, 8'd3, 8'd4 }
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
