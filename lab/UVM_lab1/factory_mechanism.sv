
package factory_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class trans extends uvm_object;
    bit[31:0] data;
    `uvm_object_utils(trans)
    function new(string name = "trans");
      super.new(name);
      `uvm_info("CREATE", $sformatf("trans type [%s] created", name), UVM_LOW)
    endfunction
  endclass

  class bad_trans extends trans;
    bit is_bad = 1;
    `uvm_object_utils(bad_trans)
    function new(string name = "trans");
      super.new(name);
      `uvm_info("CREATE", $sformatf("bad_trans type [%s] created", name), UVM_LOW)
    endfunction
  endclass

  class unit extends uvm_component;
    `uvm_component_utils(unit)
    function new(string name = "unit", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info("CREATE", $sformatf("unit type [%s] created", name), UVM_LOW)
    endfunction
  endclass

  class big_unit extends unit;
    bit is_big = 1;
    `uvm_component_utils(big_unit)
    function new(string name = "bit_unit", uvm_component parent = null);
      super.new(name, parent);
      `uvm_info("CREATE", $sformatf("big_unit type [%s] created", name), UVM_LOW)
    endfunction
  endclass

  class top extends uvm_test;
    `uvm_component_utils(top)
    function new(string name = "top", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #1us;
      phase.drop_objection(this);
    endtask
  endclass

  class object_create extends top;
    trans t1, t2, t3, t4;
    `uvm_component_utils(object_create)
    function new(string name = "object_create", uvm_component parent = null);
      super.new(name, parent);
    endfunction    
    function void build_phase(uvm_phase phase);
      uvm_factory f = uvm_factory::get(); // get singleton factory
      super.build_phase(phase);
      t1 = new("t1"); // direct construction
      // TODO-1.1 Please use the given kinds of create methods for uvm_objects
      // create t2 with method trans::type_id::create(string name, uvm_component parent = null); 
      // create t3 with method uvm_factory method f.create_object_by_type(...) as below
      // function
      // uvm_object    create_object_by_type    (uvm_object_wrapper requested_type,  
      //                                         string parent_inst_path="",
      //                                         string name="");
      // create t4 with method create_object(...) as below
      // function uvm_object create_object (string requested_type_name,
      //                                    string name="");
	  t2 = trans::type_id::create("t2");
	  void'($cast(t3, f.create_object_by_type(trans::get_type(), get_full_name(), "t3")));
	  void'($cast(t4, create_object("trans", "t4")));
	  
	  
    endfunction
  endclass

  class object_override extends object_create;
    `uvm_component_utils(object_override)
    function new(string name = "object_override", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      // replace trans type with bad_trans type with method
      // function void set_type_override_by_type
      //                              (uvm_object_wrapper original_type, 
      //                               uvm_object_wrapper override_type,
      //                               bit replace=1)
	  set_type_override_by_type(trans::get_type(),bad_trans::get_type());
	  super.build_phase(phase);
    endfunction
  endclass

  class component_create extends top;
    unit u1, u2, u3, u4;
    `uvm_component_utils(component_create)
    function new(string name = "component_create", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      uvm_factory f = uvm_factory::get(); // get singleton factory
      super.build_phase(phase);
      u1 = new("u1"); // direct construction
      // TODO-1.2 Please use the given kinds of create methods for uvm_objects
      // create u2 with method unit::type_id::create(string name, uvm_component parent = null); 
      // create u3 with method uvm_factory method f.create_component_by_type(...) as below
      // function
      // uvm_component create_component_by_type (uvm_object_wrapper requested_type,  
      //                                         string parent_inst_path="",
      //                                         string name, 
      //                                         uvm_component parent);
      // create u4 with method create_component(...) as below
      // function uvm_component create_component (string requested_type_name, 
      //                                          string name)
	  u2 = unit::type_id::create("u2",this);
	  void'($cast(u3, f.create_component_by_type(unit::get_type(), get_full_name(), "u3", this)));
	  void'($cast(u4, create_component("unit", "u4")));
    endfunction
  endclass

  class component_override extends component_create;
    `uvm_component_utils(component_override)
    function new(string name = "component_override", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      // replace unit type with big type with method
      // function void set_type_override(string original_type_name, 
      //                                 string override_type_name,
      //                                 bit    replace=1);
	  set_type_override("unit", "big_unit");
	  super.build_phase(phase);
    endfunction
  endclass
  
endpackage

module factory_mechanism;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import factory_pkg::*;

  initial begin
    run_test(""); // empty test name
  end

endmodule
