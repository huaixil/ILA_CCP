/// \file the cache ila example of OpenPiton L2 ILA (in aim of verifying the cache coherence protocol)
///  Huaixi Lu (huaixil@princeton.edu)
///


#ifndef PMESH_L2_ILA_H__
#define PMESH_L2_ILA_H__

#include <ilang/ilang++.h>
#include <vector>

using namespace ilang;

#define NOC_MSG_WIDTH 8
#define MESI_WIDTH    2
#define DATA_WIDTH    64
#define TAG_WIDTH     26
#define FETCH_STATE_WIDTH     3
#define MSG_CACHE_TYPE_WIDTH  1
#define L2_OWNER_BITS         6
#define DIR_WIDTH    64

#define b0 BoolConst(false)
#define b1 BoolConst(true)
#define zero_data BvConst(0,DATA_WIDTH)

/// \brief the class of PMESH L2 ila
class PMESH_L2_ILA {

public:
  // --------------- MEMBERS ----------- //
  /// the ila model
  Ila model;
  
  // --------------- CONSTRUCTOR ----------- //
  PMESH_L2_ILA();
  
protected:

  // -------- Input -------- //

  ExprRef msg1_type      ;
  ExprRef msg1_data      ;
  ExprRef msg1_source    ;
  ExprRef msg1_tag       ;

  ExprRef msg3_type      ;
  ExprRef msg3_data      ;
  ExprRef msg3_source    ;
  ExprRef msg3_tag       ;

  // -------- output ------- //
  ExprRef msg2_type;

  ExprRef cache_tag;
  ExprRef cache_vd;
  ExprRef cache_state;
  ExprRef cache_data;
  ExprRef cache_owner;
  ExprRef share_list;

  // --- Internal States --- //
  ExprRef cur_msg_state     ;
  ExprRef cur_msg_type      ;
  ExprRef cur_msg_source    ;
  ExprRef cur_msg_tag       ;

  // --------------- HELPERS -------- //
  /// specify a nondeterministic value within range [low,high]
  ExprRef unknown_range(unsigned low, unsigned high);
  /// a nondeterministic choice of a or b
  static ExprRef unknown_choice(const ExprRef& a, const ExprRef& b);
  /// a nondeterminstic bitvector const of width
  static FuncRef unknown(unsigned width);
  /// a helper function to concat a vector of express
  static ExprRef lConcat(const std::vector<ExprRef> & l);
  /// use a relation
  ExprRef Map(const std::string & name, unsigned retLen, const ExprRef & val);
  /// build a map relation
  ExprRef NewMap(const std::string & name, unsigned inLen, unsigned outLen);
  /// Set update function to a map  
  void MapUpdate(InstrRef & instr, const std::string & name, const ExprRef & idx, const ExprRef & val) ;
  /// Set update function to a map
  void MapUpdate(InstrRef & instr, const std::string & name, const ExprRef & idx, 
    const ExprRef & cond, const ExprRef & val);
}; // class PMESH_L2_ILA

#endif // PMESH_L2_ILA_H__

