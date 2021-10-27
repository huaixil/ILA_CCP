/// Cache Coherence Protocol: L1.5
/// Huaixi Lu (huaixil@princeton.edu)

`include "ccp_define.h"

module l15 (
  input wire clk,
  input wire rst,

  input wire [`MSG_WIDTH - 1 : 0] msg2_type,
  input wire [`DATA_WIDTH - 1 : 0] msg2_data,
  input wire [`TAG_WIDTH - 1 : 0] msg2_tag,
  input wire [`MESI_WIDTH - 1 : 0] mesi_send,

  input wire [1:0] core_req,
  input wire [`TAG_WIDTH - 1 : 0] core_tag,
  input wire [`DATA_WIDTH - 1 : 0] core_data,

  output reg [`MSG_WIDTH - 1 : 0]  msg1_type,
  output reg [`DATA_WIDTH - 1 : 0] msg1_data,
  output reg [`TAG_WIDTH - 1 : 0]  msg1_tag,

  output reg [`MSG_WIDTH - 1 : 0]  msg3_type,
  output reg [`DATA_WIDTH - 1 : 0] msg3_data,
  output reg [`TAG_WIDTH - 1 : 0]  msg3_tag
);

// private cache structure
reg [`DATA_WIDTH - 1 : 0] cache_data;
reg [`TAG_WIDTH - 1 : 0] cache_tag;
reg [`MESI_WIDTH - 1 : 0] cache_state;

always @(posedge clk) begin
  if (rst) begin
    msg1_type <= 0;
    msg1_tag  <= 0;
    msg1_data <= 0;

    msg3_type <= 0;
    msg3_tag  <= 0;
    msg3_data <= 0;

    cache_state <= `MESI_I;
    cache_tag <= 0;
    cache_data <= 0;
  end
  else begin
    if (msg2_type != `MSG_TYPE_EMPTY) begin
      case(msg2_type)
      `MSG_TYPE_INV_FWD: begin 
          cache_state <= `MESI_I;
          msg3_type <= `MSG_TYPE_INV_FWDACK; end
      `MSG_TYPE_STORE_FWD: begin 
          cache_state <= `MESI_I;
          msg3_data <= cache_data;
          msg3_type <= `MSG_TYPE_STORE_FWDACK; end
      `MSG_TYPE_LOAD_FWD: begin 
          cache_state <= (cache_state != `MESI_I) ? `MESI_S : cache_state;
          msg3_data <= cache_data;
          msg3_type <= `MSG_TYPE_LOAD_FWDACK; end
      `MSG_TYPE_DATA_ACK: begin
          cache_state <=  mesi_send;
          cache_data <= msg2_data;
          cache_tag <= msg2_tag; 
          msg1_type <= `MSG_TYPE_EMPTY;
          msg3_type <= `MSG_TYPE_EMPTY; end
      `MSG_TYPE_NODATA_ACK: msg3_type <= `MSG_TYPE_EMPTY;
      endcase
    end
    else if (msg1_type == `MSG_TYPE_EMPTY) begin
      case(core_req)
      2'd0 : begin
        if(cache_state == `MESI_I) begin
          msg1_type <= `MSG_TYPE_LOAD_REQ;
          msg1_tag <= core_tag; end
        else if(core_tag != cache_tag) begin
          msg1_type <= `MSG_TYPE_LOAD_REQ;
          msg1_tag <= core_tag;
          if (cache_state == `MESI_M) begin
            msg3_type <= `MSG_TYPE_WB_REQ;
            msg3_data <= cache_data;
            cache_state <= `MESI_I;  end
          end
      end
      2'd1: begin
        if(cache_state == `MESI_I || cache_state == `MESI_S) begin // data updated?
          msg1_type <= `MSG_TYPE_STORE_REQ;
          msg1_tag <= core_tag;
          msg1_data <= core_data; end
        else if(core_tag != cache_tag) begin
          msg1_type <= `MSG_TYPE_STORE_REQ;
          msg1_tag <= core_tag;
          msg3_type <= (cache_state == `MESI_M) ? `MSG_TYPE_WB_REQ : `MSG_TYPE_EMPTY;
          msg3_data <= (cache_state == `MESI_M) ? cache_data : msg3_data;
          msg1_data <= core_data;
          cache_state <= (cache_state == `MESI_M) ? `MESI_I : cache_state; end
        else begin
          cache_state <= `MESI_M;
          cache_data <= core_data; end
      end
      endcase
    end
  end
end

endmodule