/// \file the ila example of Cache Coherence ILA (L1)
///  Huaixi Lu (huaixil@princeton.edu)
///

#include "pmesh_l1_ila.h"


/*
#define NOC_MSG_WIDTH 8
#define CORE_MSG_WIDTH 2
#define MESI_WIDTH 2
#define DATA_WIDTH  64
#define TAG_WIDTH 26
#define DIR_WIDTH            64
*/

PMESH_L1_ILA::PMESH_L1_ILA()
    : // construct the model
      model("PMESH_L1_ILA"),

      // Input: l2 --> noc2 requests
      // not specifying these updates:   
      msg2_type       (model.NewBvInput("msg2_type", NOC_MSG_WIDTH) ),
      msg2_data       (model.NewBvInput("msg2_data", DATA_WIDTH) ),
      msg2_tag        (model.NewBvInput("msg2_tag", TAG_WIDTH) ),
      mesi_send       (model.NewBvInput("mesi_send", MESI_WIDTH)),

      core_req        (model.NewBvInput("core_req", 2)), // read or write or nothing
      core_tag        (model.NewBvInput("core_tag", TAG_WIDTH)),
      core_data       (model.NewBvInput("core_data", DATA_WIDTH)),

      // architecture states
      cache_state     (model.NewBvState("cache_state", MESI_WIDTH)),
      cache_tag       (model.NewBvState("cache_tag", TAG_WIDTH)),
      cache_data      (model.NewBvState("cache_data",  DATA_WIDTH)),

      // Outputs
      // NOC1
      msg1_type       (model.NewBvState("msg1_type", NOC_MSG_WIDTH)),
      msg1_data       (model.NewBvState("msg1_data", DATA_WIDTH)), // only used in WB?
      msg1_tag        (model.NewBvState("msg1_tag", TAG_WIDTH)),

      // NOC3
      msg3_type       (model.NewBvState("msg3_type", NOC_MSG_WIDTH)),
      msg3_data       (model.NewBvState("msg3_data", DATA_WIDTH)),
      msg3_tag        (model.NewBvState("msg3_tag", TAG_WIDTH))
// -----------------------------------------------------------------------------------------------

{
  // ------------------------------ CONSTANTS ---------------------------------- //

  // MSG TYPES
  auto L2_MSG_WIDTH  = NOC_MSG_WIDTH;
  // Requests from L15 to L2
/*
  // auto MSG_TYPE_RESERVED           =BvConst(0, L2_MSG_WIDTH);

  // auto MSG_TYPE_PREFETCH_REQ       =BvConst(1, L2_MSG_WIDTH);
*/
  auto MSG_TYPE_EMPTY              =BvConst(0, L2_MSG_WIDTH);
  auto MSG_TYPE_STORE_REQ          =BvConst(2, L2_MSG_WIDTH);
/*
  // auto MSG_TYPE_BLK_STORE_REQ      =BvConst(3, L2_MSG_WIDTH);
  // auto MSG_TYPE_BLKINIT_STORE_REQ  =BvConst(4, L2_MSG_WIDTH);
  // auto MSG_TYPE_CAS_REQ            =BvConst(5, L2_MSG_WIDTH);
  // auto MSG_TYPE_CAS_P1_REQ         =BvConst(6, L2_MSG_WIDTH); 
*/
  auto MSG_TYPE_LOAD_REQ           =BvConst(31, L2_MSG_WIDTH);
/*
  // condition satisfied
  // auto MSG_TYPE_CAS_P2Y_REQ        =BvConst(7, L2_MSG_WIDTH);
  // condition not satisfied
  // auto MSG_TYPE_CAS_P2N_REQ        =BvConst(8, L2_MSG_WIDTH);
  // Both SWAP and LDSTUB are the same for L2
  // auto MSG_TYPE_SWAP_REQ           =BvConst(9, L2_MSG_WIDTH);
  // auto MSG_TYPE_SWAP_P1_REQ        =BvConst(10, L2_MSG_WIDTH);
  // auto MSG_TYPE_SWAP_P2_REQ        =BvConst(11, L2_MSG_WIDTH);
*/
  auto MSG_TYPE_WB_REQ             =BvConst(12, L2_MSG_WIDTH);
  auto MSG_TYPE_WBGUARD_REQ        =BvConst(13, L2_MSG_WIDTH);
/*
  // auto MSG_TYPE_NC_LOAD_REQ        =BvConst(14, L2_MSG_WIDTH);
  // auto MSG_TYPE_NC_STORE_REQ       =BvConst(15, L2_MSG_WIDTH);
  // auto MSG_TYPE_INTERRUPT_FWD      =BvConst(32, L2_MSG_WIDTH);

  //RISC-V AMO requests
  // auto MSG_TYPE_AMO_ADD_REQ         =BvConst(36, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_AND_REQ         =BvConst(37, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_OR_REQ          =BvConst(38, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_XOR_REQ         =BvConst(39, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MAX_REQ         =BvConst(40, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MAXU_REQ        =BvConst(41, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MIN_REQ         =BvConst(42, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MINU_REQ        =BvConst(43, L2_MSG_WIDTH);
  // RISC-V AMO L2-internal phase 1
  // auto MSG_TYPE_AMO_ADD_P1_REQ      =BvConst(44, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_AND_P1_REQ      =BvConst(45, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_OR_P1_REQ       =BvConst(46, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_XOR_P1_REQ      =BvConst(47, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MAX_P1_REQ      =BvConst(48, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MAXU_P1_REQ     =BvConst(49, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MIN_P1_REQ      =BvConst(50, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MINU_P1_REQ     =BvConst(51, L2_MSG_WIDTH);
  // RISC-V AMO L2-internal phase 2
  // auto MSG_TYPE_AMO_ADD_P2_REQ      =BvConst(52, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_AND_P2_REQ      =BvConst(53, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_OR_P2_REQ       =BvConst(54, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_XOR_P2_REQ      =BvConst(55, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MAX_P2_REQ      =BvConst(56, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MAXU_P2_REQ     =BvConst(57, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MIN_P2_REQ      =BvConst(58, L2_MSG_WIDTH);
  // auto MSG_TYPE_AMO_MINU_P2_REQ     =BvConst(59, L2_MSG_WIDTH);
  // auto MSG_TYPE_LR_REQ              =BvConst(60, L2_MSG_WIDTH);
*/

  //Forward requests from L2 to L15
  auto MSG_TYPE_LOAD_FWD           =BvConst(16, L2_MSG_WIDTH);
  auto MSG_TYPE_STORE_FWD          =BvConst(17, L2_MSG_WIDTH);
  auto MSG_TYPE_INV_FWD            =BvConst(18, L2_MSG_WIDTH);
  //Memory requests from L2 to DRAM
  auto MSG_TYPE_LOAD_MEM           =BvConst(19, L2_MSG_WIDTH);
  auto MSG_TYPE_STORE_MEM          =BvConst(20, L2_MSG_WIDTH);
  //Forward acks from L15 to L2
  auto MSG_TYPE_LOAD_FWDACK        =BvConst(21, L2_MSG_WIDTH);
  auto MSG_TYPE_STORE_FWDACK       =BvConst(22, L2_MSG_WIDTH);
  auto MSG_TYPE_INV_FWDACK         =BvConst(23, L2_MSG_WIDTH);
  //Memory acks from memory to L2
  auto MSG_TYPE_LOAD_MEM_ACK       =BvConst(24, L2_MSG_WIDTH);
  auto MSG_TYPE_STORE_MEM_ACK      =BvConst(25, L2_MSG_WIDTH);
  // auto MSG_TYPE_NC_LOAD_MEM_ACK    =BvConst(26, L2_MSG_WIDTH);
  // auto MSG_TYPE_NC_STORE_MEM_ACK   =BvConst(27, L2_MSG_WIDTH);
  // Acks from L2 to L15
  auto MSG_TYPE_NODATA_ACK         =BvConst(28, L2_MSG_WIDTH);
  auto MSG_TYPE_DATA_ACK           =BvConst(29, L2_MSG_WIDTH);
  /*
   // auto MSG_TYPE_ERROR              =BvConst(30, L2_MSG_WIDTH);
   // auto MSG_TYPE_INTERRUPT          =BvConst(33, L2_MSG_WIDTH);
   // Only exist within L2
   // auto MSG_TYPE_L2_LINE_FLUSH_REQ   =BvConst(34, L2_MSG_WIDTH);
   // auto MSG_TYPE_L2_DIS_FLUSH_REQ    =BvConst(35, L2_MSG_WIDTH);
  */

  auto MESI_I   =   BvConst(0, MESI_WIDTH);
  auto MESI_S   =   BvConst(1, MESI_WIDTH);
  auto MESI_E   =   BvConst(2, MESI_WIDTH);
  auto MESI_M   =   BvConst(3, MESI_WIDTH);

  auto ReqRd    = BvConst(0, CORE_MSG_WIDTH);
  auto ReqExRd  = BvConst(1, CORE_MSG_WIDTH);
  auto ReqWb    = BvConst(2, CORE_MSG_WIDTH);

  // ---------------------------- Intial States -------------------------------- //
  model.AddInit(cache_state == MESI_I);
  model.AddInit(msg1_type == BvConst(0, L2_MSG_WIDTH));

  // -------------------------- Cache Operation Condition --------------------------//

  auto tag_hit = (core_tag == cache_tag);

  // ------------------------------ INSTRUCTIONS ---------------------------------- //

  // L2 fetch function -- what corresponds to instructions on L2 NOC1/NOC3 interface
  model.SetFetch( lConcat({msg2_type, msg1_type, core_req}) );
  // Valid instruction: what means to have valid command (valid = 1)
  model.SetValid( BoolConst(true) );

  // add instructions

  // ************************************ //
  // update msg3                         //
  // Response to L2:                     //
  // Forward: downgrade cache states     //
  // ************************************ //

  // LOAD_FWD
  {
    auto instr = model.NewInstr("LOAD_FWD");

    instr.SetDecode(msg2_type == MSG_TYPE_LOAD_FWD);
    
    // E or M downgrades to S, since there are two private caches own the data
    instr.SetUpdate(cache_state, Ite(cache_state != MESI_I, MESI_S, cache_state));
    // update L2 cache data
    instr.SetUpdate(msg3_data, cache_data);
    instr.SetUpdate(msg3_type, MSG_TYPE_LOAD_FWDACK);

  }

  // STORE_FWD
  {
    auto instr = model.NewInstr("STORE_FWD");

    instr.SetDecode(msg2_type == MSG_TYPE_STORE_FWD);

    // E or M downgrades to I, since there are two private caches own the data
    instr.SetUpdate(cache_state, MESI_I);
    // update L2 cache data
    instr.SetUpdate(msg3_data, cache_data); 
    instr.SetUpdate(msg3_type, MSG_TYPE_STORE_FWDACK);
  }

  // INV_FWDACK
  {
    auto instr = model.NewInstr("INV_FWD");

    instr.SetDecode(msg2_type == MSG_TYPE_INV_FWD);
    
    instr.SetUpdate(cache_state, MESI_I);
    instr.SetUpdate(msg3_type, MSG_TYPE_INV_FWDACK);
  }

  // DATA_ACK
  {
    auto instr = model.NewInstr("DATA_ACK");

    instr.SetDecode(msg2_type == MSG_TYPE_DATA_ACK);
    
    instr.SetUpdate(msg1_type, MSG_TYPE_EMPTY);
    instr.SetUpdate(msg3_type, MSG_TYPE_EMPTY);
    instr.SetUpdate(cache_data, msg2_data);
    instr.SetUpdate(cache_tag, msg2_tag);
    instr.SetUpdate(cache_state, mesi_send);
  }

  // NODATA_ACK
  {
    auto instr = model.NewInstr("NODATA_ACK");

    instr.SetDecode(msg2_type == MSG_TYPE_NODATA_ACK);
    
    instr.SetUpdate(msg3_type, MSG_TYPE_EMPTY);
  }

  // Core Requests: Read && Write && Write Back
  // ************************************ //
  // update msg1                          //
  // Req to L2:                           //
  // ************************************ //

  // read
  {
    auto instr = model.NewInstr("read");
    instr.SetDecode(core_req == ReqRd & msg1_type == MSG_TYPE_EMPTY & msg2_type == MSG_TYPE_EMPTY);

    // nothing change and return the value if there is a valid tag hit
    // else, send request to L2
    instr.SetUpdate(msg1_type, Ite(cache_state == MESI_I, MSG_TYPE_LOAD_REQ, Ite(!tag_hit, MSG_TYPE_LOAD_REQ, msg1_type)));
    instr.SetUpdate(msg1_tag, core_tag);

    instr.SetUpdate(msg3_type, Ite(!tag_hit & (cache_state == MESI_M), MSG_TYPE_WB_REQ, msg3_type));
    instr.SetUpdate(cache_state, Ite(!tag_hit & cache_state == MESI_M, MESI_I, cache_state) );
    instr.SetUpdate(msg3_data, Ite(!tag_hit& (cache_state == MESI_M), cache_data, msg3_data));
  }

  // write
  {
    auto instr = model.NewInstr("write");
    instr.SetDecode(core_req == ReqExRd & msg1_type == MSG_TYPE_EMPTY & msg2_type == MSG_TYPE_EMPTY);

    instr.SetUpdate(msg1_type,Ite( (cache_state == MESI_I) | (cache_state == MESI_S), MSG_TYPE_STORE_REQ, Ite(!tag_hit, MSG_TYPE_STORE_REQ, msg1_type)));
    instr.SetUpdate(msg1_tag, core_tag);
    instr.SetUpdate(msg1_data, core_data);

    instr.SetUpdate(cache_state, Ite(tag_hit & cache_state == MESI_E, MESI_M, Ite(!tag_hit & (cache_state == MESI_M) , MESI_I, cache_state)) );
    instr.SetUpdate(cache_data, Ite(tag_hit & (cache_state == MESI_E | cache_state == MESI_M), core_data, cache_data) );
    
    instr.SetUpdate(msg3_type, Ite(!tag_hit & (cache_state == MESI_M), MSG_TYPE_WB_REQ, msg3_type));
    instr.SetUpdate(msg3_data, Ite(!tag_hit & (cache_state == MESI_M), cache_data, msg3_data));
  }

}
