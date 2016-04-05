module bus
(
  clk,
  rst,
  en, // an enable signal to start feeding data to FFT
  ss, // addresses for each sample
  rom_data,
  rom_addr,
  pOut,
  nextSampleBtn,
  full_row,
  test_reg
);
`define bitWidth 16
`define rom_addr_size 10


parameter
          bw = 31,
          im_size = 32,
          im_s = im_size -1;
         
integer i,j,k;

input clk, rst, en, nextSampleBtn;
input [bw:0] rom_data;


output full_row;
output [3:0] ss;
output [9:0] rom_addr;
output [bw:0] pOut [0:im_s];
output [bw:0] test_reg [0:im_s];

reg full_row;
reg [3:0] ss;
reg [4:0] row_count;
reg [bw:0] pOut [0:im_s];
reg [bw:0] test_reg [0:im_s];
reg [9:0] rom_addr;

always@(posedge clk or negedge rst) begin
  if(rst == 1'b0) begin
    for(i=0;i<im_size;i=i+1) begin
      pOut[i] <= `bitWidth'd0;
    end
    rom_addr <= `rom_addr_size'd0;
    ss <= 4'd0;
//    full_row <= 1'b0;
  ////////////////////////////////////////
  //        next sample button
  ////////////////////////////////////////
  end else if (nextSampleBtn == 1'b1) begin
    rom_addr <= `rom_addr_size'd0; 
    ss <= ss + 4'd1;
    row_count <= 5'd0;
  ////////////////////////////////////////
  //      shift in data
  ////////////////////////////////////////
  end else if(en == 1'b1) begin
    if(row_count <= 6'd32) begin
      pOut[0] <= rom_data;
      for(i=1;i<im_size;i=i+1) begin
        pOut[i] <= pOut[i-1]; // shift
      end
      rom_addr <= rom_addr + `rom_addr_size'd1;
      row_count <= row_count + 5'd1;
      full_row <= 1'b0;
    end else if(row_count == 6'd33) begin
      row_count <= row_count + 6'd1;
      full_row <= 1'b1;
      rom_addr <= rom_addr; // dont incriment address
    end else if( row_count == 6'd34) begin
      row_count <= 6'd0;
      rom_addr <= rom_addr;
      full_row <= 1'b0;
      // shift into FFT
      for(i=0;i<im_size;i=i+1) begin
        test_reg[i] <= pOut[i];
      end
      
    end
  end
    
end
endmodule
