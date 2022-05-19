
`ifndef TEMPLATE_SLAVE_DRIVER_SVH
`define TEMPLATE_SLAVE_DRIVER_SVH

class template_slave_driver extends uvm_driver #(template_transfer);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  template_config cfg;

  // USER: Add your fields here

  // This macro performs UVM object creation, type control manipulation, and 
  // factory registration
  `uvm_component_utils_begin(template_slave_driver)
     // USER: Register fields here
  `uvm_component_utils_end

  // new - constructor
  extern function new (string name, uvm_component parent);

  // uvm run phase
  extern virtual task run();

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////

  // The virtual interface used to drive and view HDL signals.
  virtual template_if vif;

  // This is the method that is responsible for getting sequence transactions 
  // and driving the transaction into the DUT
  extern virtual protected task get_and_drive();
  
  // This method drives a sequence trasnaction onto the interface
  extern virtual protected task drive_transfer(template_transfer trans);

  // This method that is responsible for sending an idle cycle to the DUT
  extern protected task send_idle();

  // This method drives the DUT into reset 
  extern protected task reset_signals();
  
endclass : template_slave_driver

`endif // TEMPLATE_SLAVE_DRIVER_SVH
