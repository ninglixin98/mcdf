
`ifndef TEMPLATE_TRANSFER_SV
`define TEMPLATE_TRANSFER_SV

//------------------------------------------------------------------------------
//
// transfer enums, parameters, and events
//
//------------------------------------------------------------------------------
typedef enum {TEMPLATE_BOGUS_VAL } template_trans_kind;


//------------------------------------------------------------------------------
//
// CLASS: template_transfer
//
//------------------------------------------------------------------------------

class template_transfer extends uvm_sequence_item;
  // USER: Add transaction fields
  rand template_trans_kind      trans_kind; 

   // USER: Add constraint blocks
  `uvm_object_utils_begin(template_transfer)
    `uvm_field_enum     (template_trans_kind, trans_kind, UVM_ALL_ON)
    // USER: Register fields here
  `uvm_object_utils_end

  // new - constructor
  function new (string name = "template_transfer_inst");
    super.new(name);
  endfunction : new


endclass : template_transfer

`endif // TEMPLATE_TRANSFER_SV

