/// Cache Coherence Protocol
/// Huaixi Lu (huaixil@princeton.edu)

`include "ccp_define.h" 

module ccp_ila (
  input wire clk,
  input wire rst
);

// Channel 1
wire [`MSG_WIDTH - 1 : 0]  msg1_type;
wire [`DATA_WIDTH - 1 : 0] msg1_data;
wire [`TAG_WIDTH - 1 : 0]  msg1_tag;
wire [`OWNER_BITS - 1 : 0] msg1_source;

// Channel 2
wire [`MSG_WIDTH - 1 : 0] msg2_type;
wire [`DATA_WIDTH - 1 : 0] msg2_data;
wire [`TAG_WIDTH - 1 : 0] msg2_tag;
wire [`MESI_WIDTH - 1 : 0] mesi_send;

wire [`OWNER_BITS - 1 : 0] cache_owner;
wire [`DIR_WIDTH - 1 : 0] share_list;

// Channel 3
wire [`MSG_WIDTH - 1 : 0]  msg3_type;
wire [`DATA_WIDTH - 1 : 0] msg3_data;
wire [`TAG_WIDTH - 1 : 0]  msg3_tag;
wire [`OWNER_BITS - 1 : 0] msg3_source;


L15cmp_mem_ila pcache_mem(
  .clk (clk),
  .rst (rst),

  .msg2_type (msg2_type),
  .msg2_data (msg2_data),
  .msg2_tag  (msg2_tag),
  .mesi_send (mesi_send),
 
  .cache_owner(cache_owner),
  .share_list (share_list),
 
  .msg1_type (msg1_type),
  .msg1_data (msg1_data),
  .msg1_tag (msg1_tag),
  .msg1_source (msg1_source),

  .msg3_type (msg3_type),
  .msg3_data (msg3_data),
  .msg3_tag (msg3_tag),
  .msg3_source (msg3_source)
);

PMESH_L2_ILA l2(  
  .clk (clk),
  .rst (rst),
  .__ILA_PMESH_L2_ILA_grant__ (8'b11111111),

  .msg1_type (msg1_type),
  .msg1_data (msg1_data),
  .msg1_tag (msg1_tag),
  .msg1_source (msg1_source),

  .msg3_type (msg3_type),
  .msg3_data (msg3_data),
  .msg3_tag (msg3_tag),
  .msg3_source (msg3_source),

  .__ILA_PMESH_L2_ILA_acc_decode__ (),
  .__ILA_PMESH_L2_ILA_decode_of_INV_FWDACK__ (),
  .__ILA_PMESH_L2_ILA_decode_of_LOAD_FWDACK__ (),
  .__ILA_PMESH_L2_ILA_decode_of_LOAD_MEM_ACK__ (),
  .__ILA_PMESH_L2_ILA_decode_of_LOAD_REQ__ (),
  .__ILA_PMESH_L2_ILA_decode_of_STORE_FWDACK__ (),
  .__ILA_PMESH_L2_ILA_decode_of_STORE_MEM_ACK__ (),
  .__ILA_PMESH_L2_ILA_decode_of_STORE_REQ__ (),
  .__ILA_PMESH_L2_ILA_decode_of_WB_REQ__ (),
  .__ILA_PMESH_L2_ILA_valid__ (),

  .msg2_type (msg2_type),
  .msg2_data (msg2_data),
  .msg2_tag  (msg2_tag),
  .mesi_send (mesi_send),
 
  .cache_owner(cache_owner),
  .share_list (share_list),
  
  .cache_tag (),
  .cache_vd (),
  .cache_state (),
  .cache_data (),

  .cur_msg_state (),
  .cur_msg_type (),
  .cur_msg_source (),
  .cur_msg_tag ()
);

endmodule
