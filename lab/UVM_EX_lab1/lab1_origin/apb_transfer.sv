
`ifndef APB_TRANSFER_SV
`define APB_TRANSFER_SV

//------------------------------------------------------------------------------
//
// transfer enums, parameters, and events
//
//------------------------------------------------------------------------------
typedef enum {WRITE, READ, IDLE } apb_trans_kind;


//------------------------------------------------------------------------------
//
// CLASS: apb_transfer
//
//------------------------------------------------------------------------------

class apb_transfer extends uvm_sequence_item;
  // USER: Add transaction fields
  rand apb_trans_kind      trans_kind; 
  rand int [31:0] addr;
  rand int [31:0] data;
  rand int idle_cycle;

   // USER: Add constraint blocks
  constraint csnt {soft idle_cycle == 1;};
  `uvm_object_utils_begin(apb_transfer)
    `uvm_field_enum     (apb_trans_kind, trans_kind, UVM_ALL_ON)
    // USER: Register fields here
	`uvm_field_int(addr, UVM_ALL_ON)
	`uvm_field_int(data, UVM_ALL_ON)
	`uvm_field_int(idle_cycle,UVM_ALL_ON)
  `uvm_object_utils_end

  // new - constructor
  function new (string name = "apb_transfer_inst");
    super.new(name);
  endfunction : new


endclass : apb_transfer

`endif // APB_TRANSFER_SV

