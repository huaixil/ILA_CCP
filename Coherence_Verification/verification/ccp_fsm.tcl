analyze -sva  \
  ./ccp_fsm/l2.v \
  ./ccp_fsm/l15.v \
  ./ccp_fsm/l15cmp_mem.v \
  ./ccp_fsm/ccp_fsm.v

elaborate -top ccp_fsm
clock clk
reset rst
reset -expression {rst} {:global_formal_reset} -non_resettable_regs {0}

assert -name mutual_excludion {!(pcache_mem.l15_2.cache_state == `MESI_E || pcache_mem.l15_2.cache_state == `MESI_M) || (pcache_mem.l15_1.cache_state != `MESI_E && pcache_mem.l15_1.cache_state != `MESI_M)}

assert -name share_variable {!(pcache_mem.l15_2.cache_state == `MESI_S && pcache_mem.l15_2.msg3_type != `MSG_TYPE_LOAD_FWDACK) || l2.cache_data == pcache_mem.l15_2.cache_data}

assume {counter_db != 0 || (pcache_mem.l15_0.core_req == 2'd1 && pcache_mem.l15_0.core_tag == 5 && pcache_mem.l15_0.core_data == 10)}

