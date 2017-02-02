`timescale 1 ps / 1 ps
module parallel_out_sr_tb();

reg clock;
reg reset;

reg [7:0] shift_in;

wire [7:0] shift_out;
wire [8*3-1:0] p_out;

// DUT
parallel_out_sr #(
  .DEPTH(3)
)
dut(
  .clock(clock),
  .reset(reset),
  .shift_in(shift_in),
  .shift_out(shift_out),
  .p_out(p_out)
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

  #30 // check output
  $display($time);
  $display("p_out = %h", p_out);
  if( p_out == { 8'd0, 8'd1, 8'd2}) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else

  #100
  $stop;
end

endmodule
