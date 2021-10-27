/// Cache Coherence Protocol: L1.5
/// Huaixi Lu (huaixil@princeton.edu)

`include "ccp_define.h"

module l2 (
  input wire clk,
  input wire rst,

  input wire [`MSG_WIDTH - 1 : 0]  msg1_type,
  input wire [`DATA_WIDTH - 1 : 0] msg1_data,
  input wire [`TAG_WIDTH - 1 : 0]  msg1_tag,
  input wire [`OWNER_BITS - 1 : 0] msg1_source,

  input wire [`MSG_WIDTH - 1 : 0]  msg3_type,
  input wire [`DATA_WIDTH - 1 : 0] msg3_data,
  input wire [`TAG_WIDTH - 1 : 0]  msg3_tag,
  input wire [`OWNER_BITS - 1 : 0] msg3_source,

  output reg [`MSG_WIDTH - 1 : 0] msg2_type,
  output reg [`DATA_WIDTH - 1 : 0] msg2_data,
  output reg [`TAG_WIDTH - 1 : 0] msg2_tag,
  output reg [`MESI_WIDTH - 1 : 0] mesi_send,

  output reg [`OWNER_BITS - 1 : 0] cache_owner,
  output reg [`DIR_WIDTH - 1 : 0] share_list
);

// directory cache structure
reg [`DATA_WIDTH - 1 : 0] cache_data;
reg [`TAG_WIDTH - 1 : 0]  cache_tag;
//reg [`OWNER_BITS - 1 : 0] cache_owner;

reg [`MESI_WIDTH - 1 : 0] cache_state;
reg [1 : 0]               cache_vd;

// internal FSM
reg [1 : 0]              cur_msg_state;
reg [`MSG_WIDTH - 1 : 0] cur_msg_type;
reg [`OWNER_BITS - 1: 0] cur_msg_source;
reg [`TAG_WIDTH - 1 : 0] cur_msg_tag;
reg [`DATA_WIDTH -1 : 0] cur_msg_data;

always @(posedge clk) begin
  if (rst) begin
    msg2_type <= 0;
    msg2_tag  <= 0;
    msg2_data <= 0;
    mesi_send <= `MESI_I;

    cache_state <= `MESI_I;
    cache_vd <= `INVAL;
    cache_tag <= 0;
    cache_data <= 0;
    cache_owner <= 0;
    share_list <= 0;

    cur_msg_state  <= `STATE_INVAL;
    cur_msg_type   <= 0;
    cur_msg_tag    <= 0;
    cur_msg_source <= 0;

  end
  else begin
    if (msg3_type == `MSG_TYPE_WB_REQ) begin
      cache_state <= `MESI_I;
      cache_data <= msg3_data;
      cache_vd <= `DIRTY;
      msg2_type <= `MSG_TYPE_NODATA_ACK;
      cur_msg_state <= (cur_msg_state == `STATE_WAIT) ? `STATE_PENDING: cur_msg_state;
    end
    else
    case(cur_msg_state)
    `STATE_INVAL: begin
                cur_msg_source <= msg1_source;
                cur_msg_type <= msg1_type;
                cur_msg_tag <= msg1_tag;
                cur_msg_data <= msg1_data;
                case (msg1_type)
                `MSG_TYPE_LOAD_REQ: if (cache_vd == `INVAL) begin // empty
                                        cur_msg_state <= `STATE_WAIT;                                     
                                        msg2_type <= `MSG_TYPE_LOAD_MEM;
                                        msg2_tag <= msg1_tag; 
                                      end
                                      else if (msg1_tag != cache_tag) begin // evict
                                        cur_msg_state <= `STATE_WAIT;

                                        if (cache_state == `MESI_S) msg2_type <= `MSG_TYPE_INV_FWD;
                                        else if (cache_state == `MESI_E) msg2_type <= `MSG_TYPE_STORE_FWD;
                                        else if (cache_vd == `DIRTY) begin // add LOAD further
                                          msg2_type <= `MSG_TYPE_STORE_MEM;
                                          msg2_tag <= cache_tag; 
                                          cache_vd <= `INVAL;
                                          msg2_data <= cache_data; end
                                        else begin msg2_type <= `MSG_TYPE_LOAD_MEM;
                                                   msg2_tag <= msg1_tag; end
                                      end
                                      else begin // hit
                                        if(cache_state == `MESI_E & cache_owner != msg1_source) begin
                                          msg2_type <= `MSG_TYPE_LOAD_FWD;
                                          cur_msg_state <= `STATE_WAIT;
                                        end
                                        else begin
                                          if (cache_state == `MESI_I) cache_state <= `MESI_E;
                                          cache_owner <= msg1_source;
                                          cur_msg_state <= `STATE_INVAL;
                                          msg2_type <= `MSG_TYPE_DATA_ACK;
                                          msg2_data <= cache_data;
                                          msg2_tag <= cache_tag;
                                          mesi_send <= (cache_state == `MESI_I) ? `MESI_E: cache_state;
                                          if (cache_state == `MESI_S) 
                                            share_list <= (1 << msg1_source) | share_list;
                                        end
                                      end
                `MSG_TYPE_STORE_REQ: if (cache_vd == `INVAL) begin // empty
                                        cur_msg_state <= `STATE_WAIT;                                     
                                        msg2_type <= `MSG_TYPE_LOAD_MEM;
                                        msg2_tag <= msg1_tag; 
                                      end
                                      else if (msg1_tag != cache_tag) begin // evict
                                        cur_msg_state <= `STATE_WAIT;

                                        if (cache_state == `MESI_S) msg2_type <= `MSG_TYPE_INV_FWD;
                                        else if (cache_state == `MESI_E) msg2_type <= `MSG_TYPE_STORE_FWD;
                                        else if (cache_vd == `DIRTY) begin // add LOAD further // flag to see whether enter
                                          msg2_type <= `MSG_TYPE_STORE_MEM;
                                          msg2_tag <= cache_tag; 
                                          cache_vd <= `INVAL;
                                          msg2_data <= cache_data; end
                                        else begin msg2_type <= `MSG_TYPE_LOAD_MEM;
                                                   msg2_tag <= msg1_tag; end
                                      end
                                      else begin // hit
                                        if(cache_state == `MESI_E & cache_owner != msg1_source) begin
                                          msg2_type <= `MSG_TYPE_STORE_FWD;
                                          cur_msg_state <= `STATE_WAIT;
                                        end
                                        else if (cache_state == `MESI_S) begin 
                                          msg2_type <= `MSG_TYPE_INV_FWD;
                                          cur_msg_state <= `STATE_WAIT;
                                        end
                                        else begin
                                          cache_owner <= msg1_source;
                                          cur_msg_state <= `STATE_INVAL;
                                          msg2_type <= `MSG_TYPE_DATA_ACK;
                                          msg2_data <= msg1_data;
                                          msg2_tag <= cache_tag;
                                          mesi_send <= `MESI_M;
                                          cache_state <= `MESI_E;
                                        end
                                      end
                endcase
    end
    `STATE_WAIT:  case (msg3_type)
                `MSG_TYPE_LOAD_FWDACK: begin
                  cur_msg_state <= `STATE_PENDING;
                  cache_state <=  `MESI_S;
                  cache_data <= msg3_data;
                  cache_vd <= `DIRTY;
                  share_list <= (1 << msg3_source);
                end
                `MSG_TYPE_STORE_FWDACK: begin
                  cur_msg_state <= `STATE_PENDING;
                  cache_state <= `MESI_I;
                  cache_data <= msg3_data;
                  cache_vd <= (cache_state == `MESI_E) ? `DIRTY : cache_vd;
                end
                `MSG_TYPE_INV_FWDACK: begin
                  share_list <= ~(1 << msg3_source) & share_list;
                  if ( (~(1 << msg3_source) & share_list) == 0) begin
                    cur_msg_state <= `STATE_PENDING;
                    cache_state <= `MESI_I;
                  end
                end
                `MSG_TYPE_LOAD_MEM_ACK: begin
                  cur_msg_state <= `STATE_PENDING;
                  cache_data <= msg3_data;
                  cache_tag  <= msg3_tag;
                  cache_vd <= `CLEAN;
                end
                `MSG_TYPE_STORE_MEM_ACK: cur_msg_state <= `STATE_PENDING;
                endcase
    `STATE_PENDING: case(cur_msg_type)
                  `MSG_TYPE_LOAD_REQ: if (cache_vd == `INVAL) begin // empty
                                        cur_msg_state <= `STATE_WAIT;                                     
                                        msg2_type <= `MSG_TYPE_LOAD_MEM;
                                        msg2_tag <= cur_msg_tag; 
                                      end
                                      else if (cur_msg_tag != cache_tag) begin // evict
                                        cur_msg_state <= `STATE_WAIT;
                                        if (cache_vd == `DIRTY) begin // add LOAD further
                                          msg2_type <= `MSG_TYPE_STORE_MEM;
                                          msg2_tag <= cache_tag; 
                                          cache_vd <= `INVAL;
                                          msg2_data <= cache_data; end
                                        else begin 
                                          msg2_type <= `MSG_TYPE_LOAD_MEM;
                                          msg2_tag <= cur_msg_tag; end
                                      end
                                      else begin // hit
                                        if (cache_state == `MESI_I) cache_state <= `MESI_E;
                                        cache_owner <= cur_msg_source;
                                        cur_msg_state <= `STATE_INVAL;
                                        msg2_type <= `MSG_TYPE_DATA_ACK;
                                        msg2_data <= cache_data;
                                        msg2_tag <= cache_tag;
                                        mesi_send <= (cache_state == `MESI_I) ? `MESI_E: cache_state;
                                        if (cache_state == `MESI_S) 
                                          share_list <= (1 << cur_msg_source) | share_list;
                                      end
                  `MSG_TYPE_STORE_REQ:if (cache_vd == `INVAL) begin // empty
                                        cur_msg_state <= `STATE_WAIT;                                     
                                        msg2_type <= `MSG_TYPE_LOAD_MEM;
                                        msg2_tag <= cur_msg_tag; 
                                      end
                                      else if (cur_msg_tag != cache_tag) begin // evict
                                        cur_msg_state <= `STATE_WAIT;
                                        if (cache_vd == `DIRTY) begin // add LOAD further
                                          msg2_type <= `MSG_TYPE_STORE_MEM;
                                          msg2_tag <= cache_tag; 
                                          cache_vd <= `INVAL;
                                          msg2_data <= cache_data; end
                                        else begin msg2_type <= `MSG_TYPE_LOAD_MEM;
                                                   msg2_tag <= cur_msg_tag; end
                                      end
                                      else begin // hit
                                        cache_owner <= cur_msg_source;
                                        cur_msg_state <= `STATE_INVAL;
                                        msg2_type <= `MSG_TYPE_DATA_ACK;
                                        msg2_data <= cur_msg_data;
                                        msg2_tag <= cache_tag;
                                        mesi_send <= `MESI_M;
                                        cache_state <= `MESI_E;
                                      end
                  endcase
    endcase
  end
end

endmodule