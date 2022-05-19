interface uvm_config_if;
  logic [31:0] addr;
  logic [31:0] data;
  logic [ 1:0] op;
endinterface

package uvm_config_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  class config_obj extends uvm_object;
    int comp1_var;
    int comp2_var;
    `uvm_object_utils(config_obj)
    function new(string name = "config_obj");
      super.new(name);
      `uvm_info("CREATE", $sformatf("config_obj type [%s] created", name), UVM_LOW)
    endfunction
  endclass
  
  class comp2 extends uvm_component;
    int var2;
    virtual uvm_config_if vif;  
    config_obj cfg; 
    `uvm_component_utils(comp2)
    function new(string name = "comp2", uvm_component parent = null);
      super.new(name, parent);
      var2 = 200;
      `uvm_info("CREATE", $sformatf("unit type [%s] created", name), UVM_LOW)
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", "comp2 build phase entered", UVM_LOW)
      if(!uvm_config_db#(virtual uvm_config_if)::get(this, "", "vif", vif))
        `uvm_error("GETVIF", "no virtual interface is assigned")
        
      `uvm_info("GETINT", $sformatf("before config get, var2 = %0d", var2), UVM_LOW)
      uvm_config_db#(int)::get(this, "", "var2", var2);
      `uvm_info("GETINT", $sformatf("after config get, var2 = %0d", var2), UVM_LOW)
      
      uvm_config_db#(config_obj)::get(this, "", "cfg", cfg);
      `uvm_info("GETOBJ", $sformatf("after config get, cfg.comp2_var = %0d", cfg.comp2_var), UVM_LOW)     
      
      `uvm_info("BUILD", "comp2 build phase exited", UVM_LOW)
    endfunction
  endclass

  class comp1 extends uvm_component;
    int var1;
    comp2 c2;
    config_obj cfg; 
    virtual uvm_config_if vif;
    `uvm_component_utils(comp1)
    function new(string name = "comp1", uvm_component parent = null);
      super.new(name, parent);
      var1 = 100;
      `uvm_info("CREATE", $sformatf("unit type [%s] created", name), UVM_LOW)
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", "comp1 build phase entered", UVM_LOW)
      if(!uvm_config_db#(virtual uvm_config_if)::get(this, "", "vif", vif))
        `uvm_error("GETVIF", "no virtual interface is assigned")
        
      `uvm_info("GETINT", $sformatf("before config get, var1 = %0d", var1), UVM_LOW)
      uvm_config_db#(int)::get(this, "", "var1", var1);
      `uvm_info("GETINT", $sformatf("after config get, var1 = %0d", var1), UVM_LOW)
      
      uvm_config_db#(config_obj)::get(this, "", "cfg", cfg);
      `uvm_info("GETOBJ", $sformatf("after config get, cfg.comp1_var = %0d", cfg.comp1_var), UVM_LOW)
      
      c2 = comp2::type_id::create("c2", this);
      `uvm_info("BUILD", "comp1 build phase exited", UVM_LOW)
    endfunction
  endclass

  class uvm_config_test extends uvm_test;
    comp1 c1;
    config_obj cfg;
    `uvm_component_utils(uvm_config_test)
    function new(string name = "uvm_config_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", "uvm_config_test build phase entered", UVM_LOW)
      
      cfg = config_obj::type_id::create("cfg");
      cfg.comp1_var = 100;
      cfg.comp2_var = 200;
      uvm_config_db#(config_obj)::set(this, "*", "cfg", cfg);
      
      uvm_config_db#(int)::set(this, "c1", "var1", 10);
      uvm_config_db#(int)::set(this, "c1.c2", "var2", 20);
      
      c1 = comp1::type_id::create("c1", this);
      `uvm_info("BUILD", "uvm_config_test build phase exited", UVM_LOW)
    endfunction
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info("RUN", "uvm_config_test run phase entered", UVM_LOW)
      phase.raise_objection(this);
      #1us;
      phase.drop_objection(this);
      `uvm_info("RUN", "uvm_config_test run phase exited", UVM_LOW)
    endtask
  endclass
endpackage

module uvm_config;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import uvm_config_pkg::*;
  
  uvm_config_if if0();

  initial begin
    uvm_config_db#(virtual uvm_config_if)::set(uvm_root::get(), "uvm_test_top.*", "vif", if0);
    run_test(""); // empty test name
  end

endmodule