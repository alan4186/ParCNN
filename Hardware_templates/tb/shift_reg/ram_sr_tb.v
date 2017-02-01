`timescale 1 ps / 1 ps
module ram_sr_tb();

reg clock;
reg reset;

reg [7:0] shift_in;

wire [7:0] shift_out;

// DUT
ram_sr #(
  .DEPTH(3)
)
dut(
  .clock(clock),
  .reset(reset),
  .shift_in(shift_in),
  .shift_out(shift_out)
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
  $display("shift_out = %h", shift_out);
  if( shift_out ==  8'd0) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else

  #10
  $display($time);
  $display("shift_out = %h", shift_out);
  if( shift_out ==  8'd1) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else

  #10
  $display($time);
  $display("shift_out = %h", shift_out);
  if( shift_out ==  8'd2) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else


  #100
  $stop;
end

endmodule
