
package object_methods_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  typedef enum {WRITE, READ, IDLE} op_t;  

  class trans extends uvm_object;
    bit[31:0] addr;
    bit[31:0] data;
    op_t op;
    string name;
    `uvm_object_utils_begin(trans)
      //TODO-2.1 
      //Apply field automation macros such as
      //  `uvm_field_int(ARG, FLAG)
      //  `uvm_field_enum(T, ARG, FLAG)
      //  `uvm_field_string(ARG, FLAG)
      //to register all of member variables
	  `uvm_field_int(addr, UVM_ALL_ON)
	  `uvm_field_int(data, UVM_ALL_ON)
	  `uvm_field_enum(op_t, op, UVM_ALL_ON)
	  `uvm_field_string(name, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "trans");
      super.new(name);
      `uvm_info("CREATE", $sformatf("trans type [%s] created", name), UVM_LOW)
    endfunction
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      //TODO-2.4
      //Please just try to compare all of properties of the two properties
      //and give detailed comparison messages
	  trans t;
	  $cast(t,rhs);
	  do_compare = 1;
	  if(addr == t.addr) begin
		`uvm_info("COMPARE", "t1 and t2: addr is same",UVM_LOW)
	  end
	  else begin
	    do_compare = 0;
	    `uvm_info("COMPARE", "t1 and t2: addr is different",UVM_LOW)
	  end
		
	  if(data == t.data) begin
		`uvm_info("COMPARE", "t1 and t2: data is same",UVM_LOW)
	  end
	  else begin
	    do_compare = 0;
	    `uvm_info("COMPARE", "t1 and t2: data is different",UVM_LOW)
	  end
		
	  if(op == t.op) begin
		`uvm_info("COMPARE", "t1 and t2: op is same",UVM_LOW)
	  end
	  else begin
	    do_compare = 0;
	    `uvm_info("COMPARE", "t1 and t2: op is different",UVM_LOW)
	  end
		
	  if(name == t.name) begin
		`uvm_info("COMPARE", "t1 and t2: name is same",UVM_LOW)
	  end
	  else begin
	    do_compare = 0;
	    `uvm_info("COMPARE", "t1 and t2: name is different",UVM_LOW)
	  end
    endfunction
  endclass


  class object_methods_test extends uvm_test;
    `uvm_component_utils(object_methods_test)
    function new(string name = "object_methods_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction
    task run_phase(uvm_phase phase);
      trans t1, t2;
      bit is_equal;
      phase.raise_objection(this);
      t1 = trans::type_id::create("t1");
      t1.data = 'h1FF;
      t1.addr = 'hF100;
      t1.op = WRITE;
      t1.name = "t1";
      t2 = trans::type_id::create("t2");
      t2.data = 'h2FF;
      t2.addr = 'hF200;
      t2.op = WRITE;
      t2.name = "t2";
      //TODO-2.2 
      //Use function bit compare (uvm_object rhs, uvm_comparer comparer=null)
      //to compare t1 and t2, and check the message output
      if(t1.compare(t2))
		`uvm_info("COMPARE","compare succes",UVM_LOW)
	  else
		`uvm_info("COMPARE","compare failure",UVM_LOW)
      //TODO-2.3
      //uvm_default_comparer (uvm_comparer type) is the default UVM global comparer, 
      //you would set its property like 'show_max' to ask more of the comparison result
      //Please set this property and do the compare again
	  uvm_default_comparer.show_max = 10;
	  if(t1.compare(t2))
		`uvm_info("COMPARE","compare succes",UVM_LOW)
	  else
		`uvm_info("COMPARE","compare failure",UVM_LOW)
        
      `uvm_info("COPY", "Before uvm_object copy() taken", UVM_LOW)
	  
      //TODO-2.5
      //Use uvm_object::print() method to display all of fields before copy()
      t1.print();
	  t2.print();
      `uvm_info("COPY", "After uvm_object t2 is copied to t1", UVM_LOW)
	  
      //TODO-2.6
      //Call uvm_object::copy(uvm_object rhs) to copy t2 to t1
      //and use print() and compare() to follow steps above again for them
	  t1.copy(t2);
	  t1.print();
	  t2.print();
	  if(t1.compare(t2)) begin
		`uvm_info("COMPARE","compare succes",UVM_LOW)
	  end
	  else begin
		`uvm_info("COMPARE","compare failure",UVM_LOW)
	  end
   
      phase.drop_objection(this);
    endtask
  endclass
  
endpackage

module object_methods;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import object_methods_pkg::*;

  initial begin
    run_test(""); // empty test name
  end

endmodule
