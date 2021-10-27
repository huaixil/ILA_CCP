CORE_NUMBER = 4
CORE_NUMBER_WIDTH = 2
MEM_SIZE = 8

f1 = open('./verification/ccp_eq_check.tcl', 'w+')

f1.write("analyze -sva")
f1.write(" ./ccp_ila/l2_ila.v")
f1.write(" ./ccp_fsm/l2.v")
f1.write(" ./ccp_ila/l15_ila.v")
f1.write(" ./ccp_fsm/l15.v")
f1.write(" ./ccp_ila/l15cmp_mem_ila.v")
f1.write(" ./ccp_fsm/l15cmp_mem.v")
f1.write(" ./ccp_ila/ccp_ila.v")
f1.write(" ./ccp_fsm/ccp_fsm.v")
f1.write(" ccp_eq_wrapper.v")

f1.write("\nelaborate -top ccp_eq_wrapper \n")
f1.write("clock clk \n")
f1.write("reset rst \n")
f1.write("reset -expression {rst} {:global_formal_reset} -non_resettable_regs {0} \n\n")

f1.write("assume -name same_input_core_req {")
for i in range (CORE_NUMBER):
    if i == CORE_NUMBER - 1 :
        f1.write("(ccp_fsm.pcache_mem.l15_%d.core_req == ccp_ila.pcache_mem.l15_%d.core_req)}\n" %(i,i))
    else:
        f1.write("(ccp_fsm.pcache_mem.l15_%d.core_req == ccp_ila.pcache_mem.l15_%d.core_req) && " %(i,i))

f1.write("assume -name same_input_core_data {")
for i in range (CORE_NUMBER):
    if i == CORE_NUMBER - 1 :
        f1.write("(ccp_fsm.pcache_mem.l15_%d.core_data == ccp_ila.pcache_mem.l15_%d.core_data)}\n" %(i,i))
    else:
        f1.write("(ccp_fsm.pcache_mem.l15_%d.core_data == ccp_ila.pcache_mem.l15_%d.core_data) && " %(i,i))

f1.write("assume -name same_input_core_tag {")
for i in range (CORE_NUMBER):
    if i == CORE_NUMBER - 1 :
        f1.write("(ccp_fsm.pcache_mem.l15_%d.core_tag == ccp_ila.pcache_mem.l15_%d.core_tag)}\n" %(i,i))
    else:
        f1.write("(ccp_fsm.pcache_mem.l15_%d.core_tag == ccp_ila.pcache_mem.l15_%d.core_tag) && " %(i,i))

f1.write("assert -name same_msg1_type {ccp_fsm.msg1_type == ccp_ila.msg1_type}\n")
f1.write("assert -name same_msg1_control {ccp_fsm.msg1_tag == ccp_ila.msg1_tag && ccp_fsm.msg1_source == ccp_ila.msg1_source}\n")
f1.write("assert -name same_msg2_type {ccp_fsm.msg2_type == ccp_ila.msg2_type}\n")
f1.write("assert -name same_msg2_control {!(ccp_fsm.msg2_type == `MSG_TYPE_LOAD_MEM || ccp_fsm.msg2_type == `MSG_TYPE_STORE_MEM) || ccp_fsm.msg2_tag == ccp_ila.msg2_tag}\n")
f1.write("assert -name same_msg3_type {ccp_fsm.msg3_type == ccp_ila.msg3_type}\n")
f1.write("assert -name same_msg3_control {ccp_fsm.msg3_source == ccp_ila.msg3_source && (ccp_fsm.msg3_type != `MSG_TYPE_LOAD_MEM_ACK || ccp_fsm.msg3_tag == ccp_ila.msg3_tag)}\n")
f1.write("assert -name same_cache_state {ccp_fsm.l2.cache_state == ccp_ila.l2.cache_state} \n") 
f1.write("assert -name same_cache_tag {ccp_fsm.l2.cache_tag == ccp_ila.l2.cache_tag} \n ") 
f1.write("assert -name same_cache_data {ccp_fsm.l2.cache_data == ccp_ila.l2.cache_data}\n")
