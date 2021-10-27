/// Cache Coherence Protocol
/// Huaixi Lu (huaixil@princeton.edu)

`include "ccp_define.h" 

module ccp_fsm (
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


L15cmp_mem pcache_mem(
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

l2 l2(  
  .clk (clk),
  .rst (rst),

  .msg1_type (msg1_type),
  .msg1_data (msg1_data),
  .msg1_tag (msg1_tag),
  .msg1_source (msg1_source),

  .msg3_type (msg3_type),
  .msg3_data (msg3_data),
  .msg3_tag (msg3_tag),
  .msg3_source (msg3_source),

  .msg2_type (msg2_type),
  .msg2_data (msg2_data),
  .msg2_tag  (msg2_tag),
  .mesi_send (mesi_send),
 
  .cache_owner(cache_owner),
  .share_list (share_list)
);

// reg [8 : 0] counter_db;

// always @(posedge clk) begin
//   if(rst) counter_db <= 0;
//   else counter_db <= counter_db + 1;
// end

endmodule
