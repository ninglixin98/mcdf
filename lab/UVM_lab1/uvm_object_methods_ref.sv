
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
      trans t;
      do_compare = 1;
      void'($cast(t, rhs));
      if(addr != t.addr) begin
        do_compare = 0;
        `uvm_warning("CMPERR", $sformatf("addr %8x != %8x", addr, t.addr))
      end
      if(data != t.data) begin
        do_compare = 0;
        `uvm_warning("CMPERR", $sformatf("data %8x != %8x", data, t.data))
      end
      if(op != t.op) begin
        do_compare = 0;
        `uvm_warning("CMPERR", $sformatf("op %s != %8x", op, t.op))
      end
      if(addr != t.addr) begin
        do_compare = 0;
        `uvm_warning("CMPERR", $sformatf("name %8x != %8x", name, t.name))
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
      is_equal = t1.compare(t2);
      uvm_default_comparer.show_max = 10;
      is_equal = t1.compare(t2);
      
      if(!is_equal)
        `uvm_warning("CMPERR", "t1 is not equal to t2")
      else
        `uvm_info("CMPERR", "t1 is equal to t2", UVM_LOW)
        
      `uvm_info("COPY", "Before uvm_object copy() taken", UVM_LOW)
      t1.print();
      t2.print();
      `uvm_info("COPY", "After uvm_object t2 is copied to t1", UVM_LOW)
      t1.copy(t2);
      t1.print();
      t2.print();
      `uvm_info("CMP", "Compare t1 and t2", UVM_LOW)
      is_equal = t1.compare(t2);
      if(!is_equal)
        `uvm_warning("CMPERR", "t1 is not equal to t2")
      else
        `uvm_info("CMPERR", "t1 is equal to t2", UVM_LOW)       
      
      #1us;
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
