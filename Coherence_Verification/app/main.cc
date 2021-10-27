#include <pmesh_l1_ila.h>
#include <pmesh_l2_ila.h>
#include <ilang/vtarget-out/vtarget_gen.h>

VerilogVerificationTargetGenerator::vtg_config_t SetConfiguration();
/// Build the model
int main(int argc, char **argv) {

  // build the model
  PMESH_L1_ILA l15;
  PMESH_L2_ILA l2;
  
  auto vtg_cfg = SetConfiguration();
  
  std::string verilog_file_name = "../verification/ccp_ila/l15_ila.v";
  std::ofstream fw_verilog(verilog_file_name);
  l15.model.ExportToVerilog(fw_verilog);
  fw_verilog.close();

  verilog_file_name = "../verification/ccp_ila/l2_ila.v";
  fw_verilog.open(verilog_file_name);
  l2.model.ExportToVerilog(fw_verilog);
  fw_verilog.close();
  return 0;
}

VerilogVerificationTargetGenerator::vtg_config_t SetConfiguration() {

  // set ilang option, operators like '<' will refer to unsigned arithmetics
  SetUnsignedComparison(true); 
  
  VerilogVerificationTargetGenerator::vtg_config_t ret;
  ret.CosaSolver = "z3";
  ret.CosaPyEnvironment = "/ibuild/ilang-env/bin/activate";
  ret.CosaPath = "/ibuild/CoSA";
  ret.CosaGenTraceVcd = true;

  /// other configurations
  ret.PortDeclStyle = VlgVerifTgtGenBase::vtg_config_t::NEW;
  ret.CosaGenJgTesterScript = true;
  //ret.CosaOtherSolverOptions = "--blackbox-array";
  //ret.ForceInstCheckReset = true;

  return ret;
}