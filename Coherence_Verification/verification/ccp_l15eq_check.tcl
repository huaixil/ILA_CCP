analyze -sva  \
  ./ccp_ila/l15_ila.v \
  ./ccp_fsm/l15.v \
  wrapper_l15.v

elaborate -top wrapper_l15
clock clk
reset rst
reset -expression {rst} {:global_formal_reset} -non_resettable_regs {0}

assert -name msg1_type   {msg1_type_fsm == msg1_type_ila}
assert -name msg3_type   {msg3_type_fsm == msg3_type_ila}
assert -name cache_equal {(l15_fsm.cache_tag == l15_ila.cache_tag) && (l15_fsm.cache_data == l15_ila.cache_data) && (l15_fsm.cache_state == l15_ila.cache_state)}