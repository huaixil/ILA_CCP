/// Cache Coherence Protocol Equivalence checking
/// Huaixi Lu (huaixil@princeton.edu)

`include "ccp_define.h"

module ccp_eq_wrapper (
  input wire clk,
  input wire rst
);

ccp_fsm ccp_fsm(
  .clk (clk),
  .rst (rst)
);

ccp_ila ccp_ila(
  .clk (clk),
  .rst (rst)
);

endmodule