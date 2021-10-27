# Python script in ccp
# Generate the composition of Private caches and Memory Structure
CORE_NUMBER = 4
CORE_NUMBER_WIDTH = 2
MEM_SIZE = 8

f1 = open('./verification/ccp_fsm/l15cmp_mem.v', 'w+')

f1.write("/// Cache Coherence Protocol\n")
f1.write("/// Huaixi Lu (huaixil@princeton.edu)\n\n")
f1.write('`include "ccp_define.h" \n\n')

# declare the name for module
f1.write( "module L15cmp_mem ( \n")
f1.write( "  input wire clk, \n")
f1.write( "  input wire rst, \n")
f1.write( "  // Channel 2 only needs to know where to go \n")
f1.write( "  input wire [`MSG_WIDTH - 1 : 0] msg2_type,\n")
f1.write( "  input wire [`DATA_WIDTH - 1 : 0] msg2_data,\n")
f1.write( "  input wire [`TAG_WIDTH - 1 : 0] msg2_tag,\n\n")

f1.write( "  input wire [`MESI_WIDTH - 1 : 0] mesi_send,\n \n")
f1.write( "  input wire [`OWNER_BITS - 1 : 0] cache_owner,\n")
f1.write( "  input wire [`DIR_WIDTH - 1 : 0] share_list,\n \n")

f1.write( "  output reg [`MSG_WIDTH - 1 : 0]  msg1_type,\n")
f1.write( "  output reg [`DATA_WIDTH - 1 : 0] msg1_data,\n")
f1.write( "  output reg [`TAG_WIDTH - 1 : 0]  msg1_tag,\n")
f1.write( "  output reg [`OWNER_BITS - 1 : 0] msg1_source,\n\n")

f1.write( "  output reg [`MSG_WIDTH - 1 : 0]  msg3_type,\n")
f1.write( "  output reg [`DATA_WIDTH - 1 : 0] msg3_data,\n")
f1.write( "  output reg [`TAG_WIDTH - 1 : 0]  msg3_tag,\n")
f1.write( "  output reg [`OWNER_BITS - 1 : 0] msg3_source\n")
f1.write( ");\n\n")

f1.write( "reg [`MSG_WIDTH - 1 : 0]   msg2_type_core [%d : 0];\n" % (CORE_NUMBER-1))
f1.write( "reg [`DATA_WIDTH - 1 : 0]  msg2_data_core [%d : 0];\n" % (CORE_NUMBER-1)) 
f1.write( "reg [`TAG_WIDTH - 1 : 0]   msg2_tag_core [%d : 0];\n" % (CORE_NUMBER-1)) 
f1.write( "reg [`MESI_WIDTH - 1 : 0]  mesi_send_core [%d : 0];\n\n" % (CORE_NUMBER-1)) 
f1.write( "reg [`DATA_WIDTH - 1 : 0]  mem_data [`TAG_ARRAY - 1 : 0];\n") 
f1.write( "reg [`MSG_WIDTH - 1 : 0]   msg3_type_mem;\n")
f1.write( "reg [`DATA_WIDTH - 1 : 0]  msg3_data_mem;\n")
f1.write( "reg [`TAG_WIDTH - 1 : 0]   msg3_tag_mem;\n\n")

f1.write( "wire [`MSG_WIDTH - 1 : 0]  msg1_type_core [%d : 0];\n" % (CORE_NUMBER-1)) 
f1.write( "wire [`DATA_WIDTH - 1 : 0] msg1_data_core [%d : 0];\n" % (CORE_NUMBER-1))
f1.write( "wire [`TAG_WIDTH - 1 : 0]  msg1_tag_core  [%d : 0];\n" % (CORE_NUMBER-1)) 

f1.write( "wire [`MSG_WIDTH - 1 : 0]  msg3_type_core [%d : 0];\n" % (CORE_NUMBER-1)) 
f1.write( "wire [`DATA_WIDTH - 1 : 0] msg3_data_core [%d : 0];\n" % (CORE_NUMBER-1)) 
f1.write( "wire [`TAG_WIDTH - 1 : 0]  msg3_tag_core  [%d : 0];\n \n" % (CORE_NUMBER-1))

#declare different private cache modules
for i in range(CORE_NUMBER):
  f1.write( "l15 l15_%d (\n" % (i) )
  f1.write( "  .clk (clk),\n")
  f1.write( "  .rst (rst),\n")
  f1.write( "  .msg2_type (msg2_type_core[%d]),\n" % (i) )
  f1.write( "  .msg2_data (msg2_data_core[%d]),\n" % (i) )
  f1.write( "  .msg2_tag  (msg2_tag_core[%d]),\n" % (i))
  f1.write( "  .mesi_send (mesi_send_core[%d]),\n" % (i))
  f1.write( "  .core_req (),\n")
  f1.write( "  .core_tag (),\n")
  f1.write( "  .core_data (),\n")

  f1.write( "  .msg1_type (msg1_type_core[%d]),\n"% (i) )
  f1.write( "  .msg1_data (msg1_data_core[%d]),\n"% (i) )
  f1.write( "  .msg1_tag  (msg1_tag_core[%d]), \n"% (i) )

  f1.write( "  .msg3_type (msg3_type_core[%d]),\n"% (i) )
  f1.write( "  .msg3_data (msg3_data_core[%d]),\n"% (i) )
  f1.write( "  .msg3_tag  (msg3_tag_core[%d])  \n"% (i) )
  f1.write( ");\n")

# Channel 2 : choose core to receive req from L2
f1.write( "\n// choose core to receive req from L2\n")

f1.write( "\nreg [`MSG_WIDTH - 1 : 0]  msg2_type_pre;\n")
f1.write( "reg [`OWNER_BITS - 1 : 0] cache_owner_pre;\n\n")

f1.write( "always @(posedge clk) begin\n")
f1.write( "  if (rst) begin\n")
f1.write( "    msg2_type_pre <= 0;\n")
f1.write( "    cache_owner_pre <= 0;\n")
f1.write( "  end\n")
f1.write( "  else begin\n")
f1.write( "    msg2_type_pre <= msg2_type;\n")
f1.write( "    cache_owner_pre <= cache_owner;\n")
f1.write( "  end\n")
f1.write( "end\n\n")

f1.write( "always @ * begin\n")
for i in range(CORE_NUMBER):
  f1.write("  msg2_type_core[%d] = `MSG_TYPE_EMPTY; \n" %(i))
f1.write( "  if (msg2_type == `MSG_TYPE_INV_FWD) begin\n")
for i in range(CORE_NUMBER):
  f1.write( "     if (share_list[%d]) msg2_type_core[%d] = `MSG_TYPE_INV_FWD;\n" %(i,i) )
f1.write( "  end\n")
f1.write(  "  else if (msg2_type == `MSG_TYPE_DATA_ACK && (msg2_type_pre != msg2_type || cache_owner_pre != cache_owner)) begin\n")
for i in range(CORE_NUMBER):
  f1.write("      msg2_type_core[%d] = `MSG_TYPE_NODATA_ACK; \n" %(i))
f1.write(  "      msg2_type_core[cache_owner] = `MSG_TYPE_DATA_ACK; \n")
f1.write(  "      msg2_data_core[cache_owner] = msg2_data;\n")
f1.write(  "      msg2_tag_core[cache_owner] = msg2_tag;\n")
f1.write(  "      mesi_send_core[cache_owner] = mesi_send;\n")
f1.write(  "  end\n")
f1.write( "  else if (!(msg2_type == `MSG_TYPE_STORE_MEM | msg2_type == `MSG_TYPE_LOAD_MEM | msg2_type == `MSG_TYPE_DATA_ACK)) begin\n")
f1.write( "    msg2_type_core[cache_owner] = msg2_type;\n")
f1.write( "    msg2_data_core[cache_owner] = msg2_data;\n")
f1.write( "    msg2_tag_core[cache_owner] = msg2_tag;\n")
f1.write( "    mesi_send_core[cache_owner] = mesi_send;\n")
f1.write( "  end\n")
f1.write( "end\n\n")

# mem req 
f1.write( "always @(posedge clk) begin\n")
f1.write( "  if (rst) begin\n")
for i in range(MEM_SIZE):
  f1.write( "    mem_data[%d] <= 0;\n" % (i))
f1.write( "    msg3_type_mem <= `MSG_TYPE_EMPTY; \n")
f1.write( "  end\n")
f1.write( "  else if (msg2_type == `MSG_TYPE_LOAD_MEM) begin\n")
f1.write( "    msg3_type_mem <= `MSG_TYPE_LOAD_MEM_ACK;\n")
f1.write( "    msg3_data_mem <= mem_data[msg2_tag];\n")
f1.write( "    msg3_tag_mem <= msg2_tag;\n    end\n")
f1.write( "  else if (msg2_type == `MSG_TYPE_STORE_MEM) begin\n  mem_data[msg2_tag] <= msg2_data;\n msg3_type_mem <= `MSG_TYPE_STORE_MEM_ACK;\n")
f1.write( "    end\n")
f1.write( "  else\n")
f1.write( "    msg3_type_mem <= `MSG_TYPE_EMPTY;\n")
f1.write( "end\n")

# Channel 1 : initial requests
f1.write( "\n// choose core to send to L2 (msg1)\n")
f1.write( "reg [%d - 1 : 0] pointer1;\n" %CORE_NUMBER_WIDTH)
f1.write( "reg [%d - 1 : 0] pointer1_next;\n" % CORE_NUMBER_WIDTH)

f1.write( "always @(posedge clk) begin\n")
f1.write( "  if (rst) pointer1 <= 0;\n")
f1.write( "  else\n")
f1.write( "    pointer1 <= pointer1_next;\n")
f1.write( "end\n")

f1.write( "\nalways @ * begin\n")
f1.write( "case (pointer1)\n")

for i in range(CORE_NUMBER):
  f1.write( "   %d\'d%d:" %(CORE_NUMBER_WIDTH, i) )
  f1.write( "    begin\n")
  for j in range(CORE_NUMBER):
    if j == 0:
      f1.write( "    if(msg1_type_core[%d] != `MSG_TYPE_EMPTY) begin\n" %((j+i) % CORE_NUMBER) )
    elif j == CORE_NUMBER-1:
      f1.write( "    else begin\n")
    else:
        f1.write( "   else if (msg1_type_core[%d] != `MSG_TYPE_EMPTY) begin\n" % ((j+i) % CORE_NUMBER) )
    f1.write( "      msg1_type = msg1_type_core[%d];\n" % ((j+i) % CORE_NUMBER) )
    f1.write( "      pointer1_next = %d;\n" % ((j+i+1) % CORE_NUMBER) )
    f1.write( "      msg1_source = %d;\n" % ((j+i) % CORE_NUMBER) )
    f1.write( "      msg1_tag = msg1_tag_core[%d];\n" % ((j+i) % CORE_NUMBER) )
    f1.write( "      msg1_data = msg1_data_core[%d];\n" % ((j+i) % CORE_NUMBER) )
    f1.write( "      end\n")
  f1.write( "    end\n")
f1.write( "endcase\n")
f1.write( "end\n \n")

# Channel 3: responses to L2
f1.write( "// choose core to send to L2 (msg3)\n")
f1.write( "reg [%d - 1 : 0] pointer3;\n" % CORE_NUMBER_WIDTH)
f1.write( "reg [%d - 1 : 0] pointer3_next;\n" %CORE_NUMBER_WIDTH)

f1.write( "always @(posedge clk) begin\n")
f1.write( "  if (rst) pointer3 <= 0;\n")
f1.write( "  else\n")
f1.write( "    pointer3 <= pointer3_next;\n")
f1.write( "end\n")

f1.write( "\nalways @ * begin\n")
f1.write( "if (msg3_type_mem != `MSG_TYPE_EMPTY) begin\n")
f1.write( "  msg3_type = msg3_type_mem;\n")
f1.write( "  msg3_data = msg3_data_mem;\n")
f1.write( "  msg3_tag  = msg3_tag_mem;\n")
f1.write( "end\n")
f1.write ("else\n")
f1.write( "case (pointer3)\n")
for i in range(CORE_NUMBER):
  f1.write( "   %d\'d%d:" %(CORE_NUMBER_WIDTH, i) )
  f1.write( "   begin\n")
  for j in range(CORE_NUMBER):
    if j == 0:
      f1.write( "    if(msg3_type_core[%d] != `MSG_TYPE_EMPTY) begin\n" %((j+i) % CORE_NUMBER) )
    elif j == CORE_NUMBER-1:
      f1.write( "    else begin\n")
    else:
        f1.write( "    else if (msg3_type_core[%d] != `MSG_TYPE_EMPTY) begin\n" % ((j+i) % CORE_NUMBER) )
    f1.write( "      msg3_type = msg3_type_core[%d];\n" % ((j+i) % CORE_NUMBER) )
    f1.write( "      pointer3_next = %d;\n" % ((j+i+1) % CORE_NUMBER) )
    f1.write( "      msg3_source = %d;\n" % ((j+i) % CORE_NUMBER) )
    f1.write( "      msg3_tag = msg3_tag_core[%d];\n" % ((j+i) % CORE_NUMBER) )
    f1.write( "      msg3_data = msg3_data_core[%d];\n" % ((j+i) % CORE_NUMBER) )
    f1.write( "      end\n")
  f1.write( "    end\n")
f1.write( "endcase\n")
f1.write( "end\n")

f1.write( "endmodule\n")
f1.close()