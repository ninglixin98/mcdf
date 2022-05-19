
package uvm_message_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  class config_obj extends uvm_object;
    `uvm_object_utils(config_obj)
    function new(string name = "config_obj");
      super.new(name);
      `uvm_info("CREATE", $sformatf("config_obj type [%s] created", name), UVM_LOW)
    endfunction
  endclass
  
  class comp2 extends uvm_component;
    `uvm_component_utils(comp2)
    function new(string name = "comp2", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info("CREATE", $sformatf("unit type [%s] created", name), UVM_LOW)
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", "comp2 build phase entered", UVM_LOW)
      `uvm_info("BUILD", "comp2 build phase exited", UVM_LOW)
    endfunction
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info("RUN", "comp2 run phase entered", UVM_LOW)
      `uvm_info("RUN", "comp2 run phase exited", UVM_LOW)
    endtask
  endclass

  class comp1 extends uvm_component;
    `uvm_component_utils(comp1)
    function new(string name = "comp1", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info("CREATE", $sformatf("unit type [%s] created", name), UVM_LOW)
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", "comp1 build phase entered", UVM_LOW)
      `uvm_info("BUILD", "comp1 build phase exited", UVM_LOW)
    endfunction
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info("RUN", "comp1 run phase entered", UVM_LOW)
      `uvm_info("RUN", "comp1 run phase exited", UVM_LOW)
    endtask
  endclass

  class uvm_message_test extends uvm_test;
    config_obj cfg;
    comp1 c1;
    comp2 c2;
    `uvm_component_utils(uvm_message_test)
    function new(string name = "uvm_message_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", "uvm_message_test build phase entered", UVM_LOW)
      cfg = config_obj::type_id::create("cfg");
      c1 = comp1::type_id::create("c1", this);
      c2 = comp2::type_id::create("c2", this);

      //TODO-5.1
      //Use set_report_verbosity_level_hier() to disable all of UVM messages
      //under the uvm_message_test
      // set_report_verbosity_level_hier(UVM_NONE);
      
      //TODO-5.2
      //Use set_report_id_verbosity_level_hier() to disable all of 
      //"CREATE", "BUILD", "RUN" ID message under the uvm_message_test
      // Think why message "CREATE" could not be disabled ?
      //set_report_id_verbosity_hier("BUILD", UVM_NONE);
      //set_report_id_verbosity_hier("CREATE", UVM_NONE);
      //set_report_id_verbosity_hier("RUN", UVM_NONE);
      
      //TODO-5.3
      //Why the UVM message from config_obj type and uvm_message module
      //could not be disabled? Please use the message filter methods
      //to disable them
      // uvm_root::get().set_report_id_verbosity_hier("CREATE", UVM_NONE);
      // uvm_root::get().set_report_id_verbosity_hier("BUILD", UVM_NONE);
      // uvm_root::get().set_report_id_verbosity_hier("RUN", UVM_NONE);
      `uvm_info("BUILD", "uvm_message_test build phase exited", UVM_LOW)
    endfunction
    
    // NOTE::
    // Try to put the set_report_XXX function below inside
    // end_of_elaboration_phase and check the differences with the function
    // call inside build_phase
    //
    // set verbosity with 'hier' function must be applied once all
    // sub-components are created
    function void end_of_elaboration_phase(uvm_phase phase);
      //TODO-5.2
      //Use set_report_id_verbosity_level_hier() to disable all of 
      //"CREATE", "BUILD", "RUN" ID message under the uvm_message_test
      // Think why message "CREATE" or "BUILD" could not be disabled ?
      //set_report_id_verbosity_hier("BUILD", UVM_NONE);
      //set_report_id_verbosity_hier("CREATE", UVM_NONE);
      //set_report_id_verbosity_hier("RUN", UVM_NONE);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info("RUN", "uvm_message_test run phase entered", UVM_LOW)
      phase.raise_objection(this);
      phase.drop_objection(this);
      `uvm_info("RUN", "uvm_message_test run phase exited", UVM_LOW)
    endtask
  endclass
endpackage

module uvm_message_ref;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import uvm_message_pkg::*;
  
  initial begin
    //TODO-5.3
    //Why the UVM message from config_obj type and uvm_message module
    //could not be disabled? Please use the message filter methods
    //to disable them
    // uvm_root::get().set_report_id_verbosity_hier("TOPTB", UVM_NONE);
    `uvm_info("TOPTB", "RUN TEST entered", UVM_LOW)
    run_test(""); // empty test name
    `uvm_info("TOPTB", "RUN TEST exited", UVM_LOW)
  end

endmodule