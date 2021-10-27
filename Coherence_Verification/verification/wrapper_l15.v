/// Cache Coherence Protocol Equivalence checking
/// Huaixi Lu (huaixil@princeton.edu)

`include "ccp_define.h"

module wrapper_l15 (
  input wire clk,
  input wire rst
);

// Input

wire [`DATA_WIDTH - 1 : 0] core_data_input;
wire [`TAG_WIDTH - 1 : 0] core_tag_input;
wire [1:0] core_req_input;
wire [`MSG_WIDTH - 1 : 0] msg2_type_input;
wire [`DATA_WIDTH - 1 : 0] msg2_data_input;
wire [`TAG_WIDTH - 1 : 0] msg2_tag_input;
wire [`MESI_WIDTH - 1 : 0] mesi_send_input;

// Output

wire [`MSG_WIDTH - 1 : 0]  msg1_type_ila;
wire [`DATA_WIDTH - 1 : 0] msg1_data_ila;
wire [`TAG_WIDTH - 1 : 0]  msg1_tag_ila;

wire [`MSG_WIDTH - 1 : 0]  msg1_type_fsm;
wire [`DATA_WIDTH - 1 : 0] msg1_data_fsm;
wire [`TAG_WIDTH - 1 : 0]  msg1_tag_fsm;

wire [`MSG_WIDTH - 1 : 0]  msg3_type_ila;
wire [`DATA_WIDTH - 1 : 0] msg3_data_ila;
wire [`TAG_WIDTH - 1 : 0]  msg3_tag_ila;

wire [`MSG_WIDTH - 1 : 0]  msg3_type_fsm;
wire [`DATA_WIDTH - 1 : 0] msg3_data_fsm;
wire [`TAG_WIDTH - 1 : 0]  msg3_tag_fsm;

PMESH_L1_ILA l15_ila (

  .__ILA_PMESH_L1_ILA_grant__ (7'b1111111),
  .clk (clk),
  .rst (rst),
  .core_data (core_data_input),
  .core_req (core_req_input),
  .core_tag (core_tag_input),
  .msg2_data (msg2_data_input),
  .msg2_type (msg2_type_input),
  .msg2_tag  (msg2_tag_input),
  .mesi_send (mesi_send_input),

  .__ILA_PMESH_L1_ILA_acc_decode__ (),
  .__ILA_PMESH_L1_ILA_decode_of_DATA_ACK__ (),
  .__ILA_PMESH_L1_ILA_decode_of_INV_FWD__ (),
  .__ILA_PMESH_L1_ILA_decode_of_LOAD_FWD__ (),
  .__ILA_PMESH_L1_ILA_decode_of_STORE_FWD__ (),
  .__ILA_PMESH_L1_ILA_decode_of_read__ (),
  .__ILA_PMESH_L1_ILA_decode_of_write__ (),
  .__ILA_PMESH_L1_ILA_valid__ (),

  .msg1_type (msg1_type_ila),
  .msg1_data (msg1_data_ila),
  .msg1_tag (msg1_tag_ila),

  .msg3_type (msg3_type_ila),
  .msg3_data (msg3_data_ila),
  .msg3_tag (msg3_tag_ila),
  
  .cache_tag (),
  .cache_state (),
  .cache_data ()
);

l15 l15_fsm (
  .clk (clk),
  .rst (rst),

  .msg2_type (msg2_type_input),
  .msg2_data (msg2_data_input),
  .msg2_tag  (msg2_tag_input),
  .mesi_send (mesi_send_input),

  .core_req (core_req_input),
  .core_tag (core_tag_input),
  .core_data (core_data_input),

  .msg1_type (msg1_type_fsm),
  .msg1_data (msg1_data_fsm),
  .msg1_tag (msg1_tag_fsm),

  .msg3_type (msg3_type_fsm),
  .msg3_data (msg3_data_fsm),
  .msg3_tag (msg3_tag_fsm)
);

endmodule