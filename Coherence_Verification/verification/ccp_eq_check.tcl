analyze -sva ./ccp_ila/l2_ila.v ./ccp_fsm/l2.v ./ccp_ila/l15_ila.v ./ccp_fsm/l15.v ./ccp_ila/l15cmp_mem_ila.v ./ccp_fsm/l15cmp_mem.v ./ccp_ila/ccp_ila.v ./ccp_fsm/ccp_fsm.v ccp_eq_wrapper.v
elaborate -top ccp_eq_wrapper 
clock clk 
reset rst 
reset -expression {rst} {:global_formal_reset} -non_resettable_regs {0} 

assume -name same_input_core_req {(ccp_fsm.pcache_mem.l15_0.core_req == ccp_ila.pcache_mem.l15_0.core_req) && (ccp_fsm.pcache_mem.l15_1.core_req == ccp_ila.pcache_mem.l15_1.core_req) && (ccp_fsm.pcache_mem.l15_2.core_req == ccp_ila.pcache_mem.l15_2.core_req) && (ccp_fsm.pcache_mem.l15_3.core_req == ccp_ila.pcache_mem.l15_3.core_req)}
assume -name same_input_core_data {(ccp_fsm.pcache_mem.l15_0.core_data == ccp_ila.pcache_mem.l15_0.core_data) && (ccp_fsm.pcache_mem.l15_1.core_data == ccp_ila.pcache_mem.l15_1.core_data) && (ccp_fsm.pcache_mem.l15_2.core_data == ccp_ila.pcache_mem.l15_2.core_data) && (ccp_fsm.pcache_mem.l15_3.core_data == ccp_ila.pcache_mem.l15_3.core_data)}
assume -name same_input_core_tag {(ccp_fsm.pcache_mem.l15_0.core_tag == ccp_ila.pcache_mem.l15_0.core_tag) && (ccp_fsm.pcache_mem.l15_1.core_tag == ccp_ila.pcache_mem.l15_1.core_tag) && (ccp_fsm.pcache_mem.l15_2.core_tag == ccp_ila.pcache_mem.l15_2.core_tag) && (ccp_fsm.pcache_mem.l15_3.core_tag == ccp_ila.pcache_mem.l15_3.core_tag)}
assert -name same_msg1_type {ccp_fsm.msg1_type == ccp_ila.msg1_type}
assert -name same_msg1_control {ccp_fsm.msg1_tag == ccp_ila.msg1_tag && ccp_fsm.msg1_source == ccp_ila.msg1_source}
assert -name same_msg2_type {ccp_fsm.msg2_type == ccp_ila.msg2_type}
assert -name same_msg2_control {!(ccp_fsm.msg2_type == `MSG_TYPE_LOAD_MEM || ccp_fsm.msg2_type == `MSG_TYPE_STORE_MEM) || ccp_fsm.msg2_tag == ccp_ila.msg2_tag}
assert -name same_msg3_type {ccp_fsm.msg3_type == ccp_ila.msg3_type}
assert -name same_msg3_control {ccp_fsm.msg3_source == ccp_ila.msg3_source && (ccp_fsm.msg3_type != `MSG_TYPE_LOAD_MEM_ACK || ccp_fsm.msg3_tag == ccp_ila.msg3_tag)}
assert -name same_cache_state {ccp_fsm.l2.cache_state == ccp_ila.l2.cache_state} 
assert -name same_cache_tag {ccp_fsm.l2.cache_tag == ccp_ila.l2.cache_tag} 
 assert -name same_cache_data {ccp_fsm.l2.cache_data == ccp_ila.l2.cache_data}
