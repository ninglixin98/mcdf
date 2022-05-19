
package phase_order_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

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
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info("CONNECT", "comp2 connect phase entered", UVM_LOW)
      `uvm_info("CONNECT", "comp2 connect phase exited", UVM_LOW)
    endfunction
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info("RUN", "comp2 run phase entered", UVM_LOW)
      `uvm_info("RUN", "comp2 run phase entered", UVM_LOW)
    endtask
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("REPORT", "comp2 report phase entered", UVM_LOW)
      `uvm_info("REPORT", "comp2 report phase exited", UVM_LOW)   
    endfunction
  endclass
  
  class comp3 extends uvm_component;
    `uvm_component_utils(comp3)
    function new(string name = "comp3", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info("CREATE", $sformatf("unit type [%s] created", name), UVM_LOW)
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", "comp3 build phase entered", UVM_LOW)
      `uvm_info("BUILD", "comp3 build phase exited", UVM_LOW)
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info("CONNECT", "comp3 connect phase entered", UVM_LOW)
      `uvm_info("CONNECT", "comp3 connect phase exited", UVM_LOW)
    endfunction
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info("RUN", "comp3 run phase entered", UVM_LOW)
      `uvm_info("RUN", "comp3 run phase entered", UVM_LOW)
    endtask
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("REPORT", "comp3 report phase entered", UVM_LOW)
      `uvm_info("REPORT", "comp3 report phase exited", UVM_LOW)   
    endfunction
  endclass
  
  class comp1 extends uvm_component;
    comp2 c2;
    comp3 c3;
    `uvm_component_utils(comp1)
    function new(string name = "comp1", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info("CREATE", $sformatf("unit type [%s] created", name), UVM_LOW)
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", "comp1 build phase entered", UVM_LOW)
      c2 = comp2::type_id::create("c2", this);
      c3 = comp3::type_id::create("c3", this);
      `uvm_info("BUILD", "comp1 build phase exited", UVM_LOW)
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info("CONNECT", "comp1 connect phase entered", UVM_LOW)
      `uvm_info("CONNECT", "comp1 connect phase exited", UVM_LOW)
    endfunction
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info("RUN", "comp1 run phase entered", UVM_LOW)
      `uvm_info("RUN", "comp1 run phase entered", UVM_LOW)
    endtask
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("REPORT", "comp1 report phase entered", UVM_LOW)
      `uvm_info("REPORT", "comp1 report phase exited", UVM_LOW)   
    endfunction
  endclass

  class phase_order_test extends uvm_test;
    comp1 c1;
    `uvm_component_utils(phase_order_test)
    function new(string name = "phase_order_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", "phase_order_test build phase entered", UVM_LOW)
      c1 = comp1::type_id::create("c1", this);
      `uvm_info("BUILD", "phase_order_test build phase exited", UVM_LOW)
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info("CONNECT", "phase_order_test connect phase entered", UVM_LOW)
      `uvm_info("CONNECT", "phase_order_test connect phase exited", UVM_LOW)
    endfunction
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info("RUN", "phase_order_test run phase entered", UVM_LOW)
      phase.raise_objection(this);
      #1us;
      phase.drop_objection(this);
      `uvm_info("RUN", "phase_order_test run phase exited", UVM_LOW)
    endtask
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("REPORT", "phase_order_test report phase entered", UVM_LOW)
      `uvm_info("REPORT", "phase_order_test report phase exited", UVM_LOW)    
    endfunction
    
    task reset_phase(uvm_phase phase);
      `uvm_info("RESET", "phase_order_test reset phase entered", UVM_LOW)
      phase.raise_objection(this);
      #1us;
      phase.drop_objection(this);
      `uvm_info("RESET", "phase_order_test reset phase exited", UVM_LOW)
    endtask
    
    task main_phase(uvm_phase phase);
      `uvm_info("MAIN", "phase_order_test main phase entered", UVM_LOW)
      phase.raise_objection(this);
      #1us;
      phase.drop_objection(this);
      `uvm_info("MAIN", "phase_order_test main phase exited", UVM_LOW)
    endtask 
  endclass
endpackage

module phase_order;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import phase_order_pkg::*;

  initial begin
    run_test(""); // empty test name
  end

endmodule