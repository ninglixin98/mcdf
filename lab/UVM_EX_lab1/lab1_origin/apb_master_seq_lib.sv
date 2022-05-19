
`ifndef APB_MASTER_SEQ_LIB_SV
`define APB_MASTER_SEQ_LIB_SV

//------------------------------------------------------------------------------
// SEQUENCE: default
//------------------------------------------------------------------------------
typedef class apb_transfer;
typedef class apb_master_sequencer;

// USER: Add your sequences here
class apb_master_base_seq extends uvm_sequence #(apb_transfer);
    function new(string name=""); 
      super.new(name);
    endfunction : new
  `uvm_object_utils(apb_master_base_seq)     
endclass : apb_master_base_seq

class apb_master_single_write_seq extends apb_master_base_seq;
	rand bit [31:0]      addr;
	rand bit [31:0]      data;
    rand apb_transfer req, rsp;
    function new(string name=""); 
      super.new(name);
    endfunction : new
    `uvm_object_utils(apb_master_single_write_seq)    
  
    virtual task body();
      `uvm_info(get_type_name(),"Starting single write sequence", UVM_HIGH)
      `uvm_do_with(req, {trans_kind == WRITE; addr == local::addr; data == local::data;}) 
	  get_response(rsp);
      `uvm_info(get_type_name(),$psprintf("Done single write sequence: %s",this_transfer.convert2string()), UVM_HIGH)
    endtask: body
endclass : apb_master_single_write_seq

class apb_master_single_read_seq extends apb_master_base_seq;
	rand bit [31:0]      addr;
	rand bit [31:0]      data;
    rand apb_transfer req, rsp;
    function new(string name=""); 
      super.new(name);
    endfunction : new
    `uvm_object_utils(apb_master_single_read_seq)    
  
    virtual task body();
      `uvm_info(get_type_name(),"Starting single read sequence", UVM_HIGH)
      `uvm_do_with(req, {trans_kind == READ; addr == local::addr;}) 
	  get_response(rsp);
	  data = rsp.data;
      `uvm_info(get_type_name(),$psprintf("Done single read sequence: %s",this_transfer.convert2string()), UVM_HIGH)
    endtask: body
endclass : apb_master_single_read_seq

class apb_master_burst_write_seq extends apb_master_base_seq;
	rand bit [31:0]      addr;
	rand bit [31:0]      data[];
    rand apb_transfer req, rsp;
	constraint cnst {soft data.size inside {4, 8, 16, 32};
					 foreach(data[i]) soft data[i] == addr + (i << 2);
					 };
    function new(string name=""); 
      super.new(name);
    endfunction : new
    `uvm_object_utils(apb_master_burst_write_seq)    
  
    virtual task body();
      `uvm_info(get_type_name(),"Starting burst write sequence", UVM_HIGH)
	  foreach(data[i]) begin
		`uvm_do_with(req, {trans_kind == WRITE; addr == local::addr + (i << 2); data == local::data[i];idle_cycle == 0;}) 
		get_response(rsp);
	  end
	  `uvm_do_with(req, {trans_kind == IDLE;})
      get_response(rsp);
      `uvm_info(get_type_name(),$psprintf("Done burst write sequence: %s",this_transfer.convert2string()), UVM_HIGH)
    endtask: body
endclass : apb_master_burst_write_seq

class apb_master_burst_read_seq extends apb_master_base_seq;
	rand bit [31:0]      addr;
	rand bit [31:0]      data[];
    rand apb_transfer req, rsp;
	constraint cnst {soft data.size inside {4, 8, 16, 32};
					 };
    function new(string name=""); 
      super.new(name);
    endfunction : new
    `uvm_object_utils(apb_master_burst_read_seq)    
  
    virtual task body();
      `uvm_info(get_type_name(),"Starting burst read sequence", UVM_HIGH)
	  foreach(data[i]) begin
		`uvm_do_with(req, {trans_kind == READ; addr == local::addr + (i << 2); idle_cycle == 0;}) 
		get_response(rsp);
		data[i] == rsp.data;
	  end
	  `uvm_do_with(req, {trans_kind == IDLE;})
      get_response(rsp);
      `uvm_info(get_type_name(),$psprintf("Done burst read sequence: %s",this_transfer.convert2string()), UVM_HIGH)
    endtask: body
endclass : apb_master_burst_read_seq

`endif // apb_MASTER_SEQ_LIB_SV

