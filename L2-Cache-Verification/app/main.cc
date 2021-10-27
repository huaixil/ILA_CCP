#include <pmesh_l2_ila.h>
#include <ilang/vtarget-out/vtarget_gen.h>

/// the function to generate configuration
VerilogVerificationTargetGenerator::vtg_config_t SetConfiguration();

void verifyPMeshL2(
  Ila& model, 
  VerilogVerificationTargetGenerator::vtg_config_t vtg_cfg,
  const std::vector<std::string> & design_files
   ) {
  VerilogGeneratorBase::VlgGenConfig vlg_cfg;
  vlg_cfg.pass_node_name = true;
  //vtg_cfg.ForceInstCheckReset = true;

  std::string RootPath    = "..";
  std::string VerilogPath = RootPath    + "/verilog/";
  std::string IncludePath = VerilogPath + "include/";
  std::string RefrelPath  = RootPath    + "/refinement/";
  std::string OutputPath  = RootPath    + "/verification/";

  std::vector<std::string> path_to_design_files;
  for(auto && f : design_files)
    path_to_design_files.push_back( VerilogPath + f );
  

  VerilogVerificationTargetGenerator vg(
      {IncludePath},                                         // one include path
      path_to_design_files,                                  // designs
      "l2",                                                  // top_module_name
      RefrelPath + "ref-rel-var-map-l2.json",                // variable mapping
      RefrelPath + "ref-rel-inst-cond-l2.json",              // conditions of start/ready
      OutputPath,                                            // output path
      model.get(),                                           // model
      VerilogVerificationTargetGenerator::backend_selector::JASPERGOLD, // backend: JASPERGOLD
      vtg_cfg,  // target generator configuration
      vlg_cfg); // verilog generator configuration

  vg.GenerateTargets();
}


/// Build the model
int main() {
  // extract the configurations
  std::vector<std::string> design_files = {
    "sram_wrappers/sram_l2_data.tmp.v",
    "sram_wrappers/sram_l2_dir.tmp.v",
    "sram_wrappers/sram_l2_state.tmp.v",
    "sram_wrappers/sram_l2_tag.tmp.v",

    "l2_amo_alu.v",
    "l2_broadcast_counter_wrap.v",
    "l2_broadcast_counter.v",
    "l2_config_regs.v",
    "l2_data_ecc.tmp.v",
    "l2_data_pgen.tmp.v",
    "l2_data_wrap.v",
    "l2_data.v",
    // "l2_debug.v",
    "l2_decoder.v",
    "l2_dir_wrap.v",
    "l2_dir.v",
    "l2_encoder.v",
    "l2_mshr_decoder.v",
    "l2_mshr_wrap.tmp.v",
    // "l2_mshr_wrap.v" // include or not? 

    "l2_pipe1_buf_in.tmp.v",
    "l2_pipe1_buf_out.tmp.v",
    "l2_pipe1_ctrl.tmp.v",
    "l2_pipe1_dpath.tmp.v",
    "l2_pipe1.v",

    "l2_pipe2_buf_in.tmp.v",
    "l2_pipe2_ctrl.tmp.v",
    "l2_pipe2_dpath.tmp.v",
    "l2_pipe2.v",

    "l2_priority_encoder.tmp.v",
    "l2_smc_wrap.v",
    "l2_smc.tmp.v",
    "l2_state_wrap.v",
    "l2_state.tmp.v",
    "l2_tag_wrap.v",
    "l2_tag.v",
    "l2.v"
  };

  auto vtg_cfg = SetConfiguration();

  // build the model
  PMESH_L2_ILA l2_ila_model;

  verifyPMeshL2(l2_ila_model.model, vtg_cfg, design_files);

  return 0;
}



VerilogVerificationTargetGenerator::vtg_config_t SetConfiguration() {

  // set ilang option, operators like '<' will refer to unsigned arithmetics
  SetUnsignedComparison(true); 
  
  VerilogVerificationTargetGenerator::vtg_config_t ret;
  ret.CosaSolver = "btor";
  ret.CosaPyEnvironment = "~/cosaEnv/bin/activate";
  ret.CosaPath = "~/CoSA";
  ret.CosaGenTraceVcd = true;
  ret.CosaAddKeep = false;

  /// other configurations
  ret.PortDeclStyle = VlgVerifTgtGenBase::vtg_config_t::NEW;
  ret.CosaGenJgTesterScript = true;
  //ret.CosaOtherSolverOptions = "--blackbox-array";
  //ret.ForceInstCheckReset = true;

  return ret;
}