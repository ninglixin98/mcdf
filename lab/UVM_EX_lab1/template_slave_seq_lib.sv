
`ifndef TEMPLATE_SLAVE_SEQ_LIB_SV
`define TEMPLATE_SLAVE_SEQ_LIB_SV

//------------------------------------------------------------------------------
// SEQUENCE: example
//------------------------------------------------------------------------------
class example_template_slave_seq extends uvm_sequence #(template_transfer);

    function new(string name=""); 
      super.new(name);
    endfunction : new
  
  `uvm_object_utils(example_template_slave_seq)    

    template_transfer this_transfer;
  
    virtual task body();
      `uvm_info(get_type_name(),"Starting example sequence", UVM_HIGH)
       `uvm_do(this_transfer) 
	
      `uvm_info(get_type_name(),$psprintf("Done example sequence: %s",this_transfer.convert2string()), UVM_HIGH)
 
    endtask
  
endclass : example_template_slave_seq

`endif // template_SLAVE_SEQ_LIB_SV

