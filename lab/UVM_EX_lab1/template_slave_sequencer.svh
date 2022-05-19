
`ifndef TEMPLATE_SLAVE_SEQUENCER_SVH
`define TEMPLATE_SLAVE_SEQUENCER_SVH

class template_slave_sequencer extends uvm_sequencer #(template_transfer);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  template_config cfg;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(template_slave_sequencer)
     // USER: Register fields 
  `uvm_component_utils_end

  // new - constructor
  extern function new (string name, uvm_component parent);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////

  // The virtual interface used to drive and view HDL signals.
  virtual template_if vif;

endclass : template_slave_sequencer

`endif // TEMPLATE_SLAVE_SEQUENCER_SVH


