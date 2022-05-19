`timescale 1ns/1ps
`include "apb_if.sv"

interface chnl_intf(input clk, input rstn);
  logic [31:0] ch_data;
  logic        ch_data_p;
  logic        ch_valid;
  logic        ch_wait;
  logic        ch_parity_err;
  clocking drv_ck @(posedge clk);
    default input #1ps output #1ps;
    output ch_data, ch_valid, ch_data_p;
    input ch_wait, ch_parity_err;
  endclocking
  clocking mon_ck @(posedge clk);
    default input #1ps output #1ps;
    input ch_data, ch_valid, ch_data_p, ch_wait, ch_parity_err;
  endclocking
endinterface

interface fmt_intf(input clk, input rstn);
  logic        fmt_ready;
  logic        fmt_valid;
  logic [31:0] fmt_data;
  logic        fmt_first;
  logic        fmt_last;
  clocking drv_ck @(posedge clk);
    default input #1ps output #1ps;
    input fmt_valid, fmt_data, fmt_first, fmt_last;
    output fmt_ready;
  endclocking
  clocking mon_ck @(posedge clk);
    default input #1ps output #1ps;
    input fmt_ready, fmt_valid, fmt_data, fmt_first, fmt_last;
  endclocking
endinterface

interface mcdf_intf(output logic clk, output logic rstn);
  // USER TODO
  // To define those signals which do not exsit in
  // reg_if, chnl_if, fmt_if
  logic [3:0] chnl_en;

  clocking mon_ck @(posedge clk);
    default input #1ps output #1ps;
    input chnl_en;
  endclocking
    
  // clock generation
  initial begin 
    clk <= 0;
    forever begin
      #5 clk <= !clk;
    end
  end
  
  // reset trigger
  initial begin 
    #10 rstn <= 0;
    repeat(10) @(posedge clk);
    rstn <= 1;
  end
endinterface

interface bind_intf(
  input logic [5:0] slv0_freeslot_bind, 
  input logic [5:0] slv1_freeslot_bind, 
  input logic [5:0] slv2_freeslot_bind, 
  input logic [5:0] slv3_freeslot_bind
);
endinterface

module tb;
  logic         clk;
  logic         rstn;

  mcdf dut(
    .clk_i               (clk                     ) ,
    .rst_n_i             (rstn                    ) ,
    .slv0_data_i         (chnl0_if.ch_data        ) , // 
    .slv0_data_p_i       (chnl0_if.ch_data_p      ) , // one bit parity of data_i
    .slv0_valid_i        (chnl0_if.ch_valid       ) , // 
    .slv0_wait_o         (chnl0_if.ch_wait        ) , //
    .slv0_parity_err_o   (chnl0_if.ch_parity_err  ) , //
    .slv1_data_i         (chnl1_if.ch_data        ) , // 
    .slv1_data_p_i       (chnl1_if.ch_data_p      ) , // one bit parity of data_i
    .slv1_valid_i        (chnl1_if.ch_valid       ) , // 
    .slv1_wait_o         (chnl1_if.ch_wait        ) , //
    .slv1_parity_err_o   (chnl1_if.ch_parity_err  ) , //
    .slv2_data_i         (chnl2_if.ch_data        ) , // 
    .slv2_data_p_i       (chnl2_if.ch_data_p      ) , // one bit parity of data_i
    .slv2_valid_i        (chnl2_if.ch_valid       ) , // 
    .slv2_wait_o         (chnl2_if.ch_wait        ) , //
    .slv2_parity_err_o   (chnl2_if.ch_parity_err  ) , //
    .slv3_data_i         (chnl3_if.ch_data        ) , // 
    .slv3_data_p_i       (chnl3_if.ch_data_p      ) , // one bit parity of data_i
    .slv3_valid_i        (chnl3_if.ch_valid       ) , // 
    .slv3_wait_o         (chnl3_if.ch_wait        ) , //
    .slv3_parity_err_o   (chnl3_if.ch_parity_err  ) , //
    .paddr_i             (reg_if.paddr[7:0]       ) ,
    .pwr_i               (reg_if.pwrite           ) ,
    .pen_i               (reg_if.penable          ) ,
    .psel_i              (reg_if.psel             ) ,
    .pwdata_i            (reg_if.pwdata           ) ,
    .prdata_o            (reg_if.prdata           ) ,
    .pready_o            (reg_if.pready           ) ,
    .pslverr_o           (reg_if.pslverr          ) , 
    .rev_rdy_i           (fmt_if.fmt_ready        ) , // receiver rdy
    .pkg_vld_o           (fmt_if.fmt_valid        ) , // data is valid
    .pkg_dat_o           (fmt_if.fmt_data         ) , // data/payload
    .pkg_fst_o           (fmt_if.fmt_first        ) , // header indicator
    .pkg_lst_o           (fmt_if.fmt_last         )   // parirty data
  );


  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import mcdf_pkg::*;

  apb_if    reg_if(.*);
  chnl_intf chnl0_if(.*);
  chnl_intf chnl1_if(.*);
  chnl_intf chnl2_if(.*);
  chnl_intf chnl3_if(.*);
  fmt_intf  fmt_if(.*);
  mcdf_intf mcdf_if(.*);

  // mcdf interface monitoring MCDF ports and signals
  assign mcdf_if.chnl_en = tb.dut.inst_reg_if.slv_en_o;
  
  initial begin 
    // do interface configuration from top tb (HW) to verification env (SW)
    uvm_config_db#(virtual chnl_intf)::set(uvm_root::get(), "uvm_test_top.env.chnl_agts[0]",  "vif",          chnl0_if);
    uvm_config_db#(virtual chnl_intf)::set(uvm_root::get(), "uvm_test_top.env.chnl_agts[1]",  "vif",          chnl1_if);
    uvm_config_db#(virtual chnl_intf)::set(uvm_root::get(), "uvm_test_top.env.chnl_agts[2]",  "vif",          chnl2_if);
    uvm_config_db#(virtual chnl_intf)::set(uvm_root::get(), "uvm_test_top.env.chnl_agts[3]",  "vif",          chnl3_if);
    uvm_config_db#(virtual apb_if   )::set(uvm_root::get(), "uvm_test_top.env.reg_agt",       "vif",          reg_if  );
    uvm_config_db#(virtual fmt_intf )::set(uvm_root::get(), "uvm_test_top.env.fmt_agt",       "vif",          fmt_if  );
    uvm_config_db#(virtual mcdf_intf)::set(uvm_root::get(), "uvm_test_top.env.*",             "mcdf_vif",     mcdf_if);
    uvm_config_db#(virtual chnl_intf)::set(uvm_root::get(), "uvm_test_top.env.*",             "chnl_vifs[0]", chnl0_if);
    uvm_config_db#(virtual chnl_intf)::set(uvm_root::get(), "uvm_test_top.env.*",             "chnl_vifs[1]", chnl1_if);
    uvm_config_db#(virtual chnl_intf)::set(uvm_root::get(), "uvm_test_top.env.*",             "chnl_vifs[2]", chnl2_if);
    uvm_config_db#(virtual chnl_intf)::set(uvm_root::get(), "uvm_test_top.env.*",             "chnl_vifs[3]", chnl3_if);
    uvm_config_db#(virtual apb_if   )::set(uvm_root::get(), "uvm_test_top.env.*",             "reg_vif",      reg_if  );
    uvm_config_db#(virtual fmt_intf )::set(uvm_root::get(), "uvm_test_top.env.*",             "fmt_vif",      fmt_if  );
    // If no external configured via +UVM_TESTNAME=my_test, the default test is
    // mcdf_data_consistence_basic_test
    run_test("mcdf_data_consistence_basic_test");
  end
  
  
  //--------------------------------------------------------
  // Example for how to probe signals
  //--------------------------------------------------------
  logic [5:0] slv0_freeslot_vlog, slv1_freeslot_vlog, slv2_freeslot_vlog, slv3_freeslot_vlog;
  logic [5:0] slv0_freeslot_mti, slv1_freeslot_mti, slv2_freeslot_mti, slv3_freeslot_mti;
  logic [5:0] slv0_freeslot_vcs, slv1_freeslot_vcs, slv2_freeslot_vcs, slv3_freeslot_vcs;
  // Verilog hierarchy probe
  assign slv0_freeslot_vlog = tb.dut.slv0_freeslot_s;
  assign slv1_freeslot_vlog = tb.dut.slv1_freeslot_s;
  assign slv2_freeslot_vlog = tb.dut.slv2_freeslot_s;
  assign slv3_freeslot_vlog = tb.dut.slv3_freeslot_s;

  // Questasim supplied probe 
  // initial begin
  //   $init_signal_spy("tb.dut.slv0_freeslot_s", "tb.slv0_freeslot_mti");
  //   $init_signal_spy("tb.dut.slv1_freeslot_s", "tb.slv1_freeslot_mti");
  //   $init_signal_spy("tb.dut.slv2_freeslot_s", "tb.slv2_freeslot_mti");
  //   $init_signal_spy("tb.dut.slv3_freeslot_s", "tb.slv3_freeslot_mti");
  // end

  // VCS supplied probe
  initial begin
    $hdl_xmr("tb.dut.slv0_freeslot_s", "tb.slv0_freeslot_vcs");
    $hdl_xmr("tb.dut.slv1_freeslot_s", "tb.slv1_freeslot_vcs");
    $hdl_xmr("tb.dut.slv2_freeslot_s", "tb.slv2_freeslot_vcs");
    $hdl_xmr("tb.dut.slv3_freeslot_s", "tb.slv3_freeslot_vcs");
  end

  // Bind interface probe
  bind tb.dut bind_intf bind_if0(
     .slv0_freeslot_bind(slv0_freeslot_s)
    ,.slv1_freeslot_bind(slv1_freeslot_s)
    ,.slv2_freeslot_bind(slv2_freeslot_s)
    ,.slv3_freeslot_bind(slv3_freeslot_s)
  );
endmodule



