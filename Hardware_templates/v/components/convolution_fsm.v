module convolution_fsm #(
  parameter P_SR_DEPTH = 2,// -1,
  parameter RAM_SR_DEPTH = 4,//-1,
  parameter NUM_SR_ROWS = 4,//-1,
  parameter MA_TREE_SIZE = 16,//-1,
  parameter MA_TREE_DEPTH = 4//-1
) (
  input clock,
  input reset,

  input row_shift_in_rdy,
  input input_start,

  output sr_enable,
  output shift_row_up,
  output conv_done
);

parameter COLUMN_MAX = RAM_SR_DEPTH;
// change P_SR_DEPTH to P_SR_HEIGHT to allow non square kernels
parameter ROW_MAX = NUM_SR_ROWS - P_SR_DEPTH + 1;

wire conv_done_pre_tree;
wire enable;
// The counter is 16 bits because the max number of elements in a
// convolution is 2^16, with more elements, overflow is possible.
// This bitwidth allows for the worst case of a 1x2^16 kernel.
reg [15:0] row_counter;
// The column counter is 16 bits for the same reason as the row counter.
reg [15:0] column_counter;

`define STATE_BW 1
reg [`STATE_BW-1:0] state;

reg [MA_TREE_DEPTH-1:0] conv_done_sr;

assign shift_row_up = (column_counter == COLUMN_MAX-1) ? 1'b1 : 1'b0;
assign conv_done_pre_tree = ( (column_counter == COLUMN_MAX-1) &
                     (row_counter == ROW_MAX-1) )  ? 1'b1 : 1'b0;

// will eventually change to depend on more input signals
assign enable = row_shift_in_rdy;
assign sr_enable = enable;
assign conv_done = conv_done_sr[MA_TREE_DEPTH-1];

// Block to shift out conv_done signal with tree
always@(posedge clock) begin
  conv_done_sr[MA_TREE_DEPTH-1:1] <= conv_done_sr[MA_TREE_DEPTH-2:0];
  conv_done_sr[0] <= conv_done_pre_tree;
end

// Block to choose next state
always@(posedge clock or negedge reset) begin
  if(reset == 1'b0) begin
    state <= `STATE_BW'd0;
  end else begin
    case(state)
      `STATE_BW'd0: // shift 1
        if(enable == 1'b0)
          state <= state;
        else if(input_start == 1'b1)
          state <= `STATE_BW'd0;
        else if(column_counter == COLUMN_MAX-2)
          state <= `STATE_BW'd1;
        else
          state <= `STATE_BW'd0;
      `STATE_BW'd1: // shift P_SR_DEPTH
        state <= `STATE_BW'd0;
      default:
        state <= `STATE_BW'd0;
    endcase
  end // reset if/else
end //always

// Block to set column and row counters
always@(posedge clock or negedge reset) begin
  if (reset == 1'b0) begin
    row_counter <= 16'd0;
    column_counter <= 16'd0;
  end else begin
    case(state)
      `STATE_BW'd0: begin // column shift
        if (enable == 1'b0) begin
          row_counter <= row_counter;
          column_counter <= column_counter;
        end else if (input_start == 1'b1) begin
          row_counter <= 16'd0;
          column_counter <= 16'd0;
        end else begin
          row_counter <= row_counter;
          column_counter <= column_counter + 16'd1;
        end
      end // state 0, column shift
      `STATE_BW'd1: begin  // shift row shift
        if (enable == 1'b0) begin
          row_counter <= row_counter;
          column_counter <= column_counter;
        end else if (input_start == 1'b1) begin
          row_counter <= 16'd0;
          column_counter <= 16'd0;
        end else begin
          // (shift by P_SR_DEPTH)
          if (row_counter == ROW_MAX-1) begin
            row_counter <= 16'd0;
          end else begin
            row_counter <= row_counter + 16'd1;
          end // row max
          column_counter <= 16'd0;
        end
      end // state 1 // row shift
      default: begin
        row_counter <= 16'd0;
        column_counter <= 16'd0;
      end // default
    endcase
  end // reset if/else
end // always

endmodule

