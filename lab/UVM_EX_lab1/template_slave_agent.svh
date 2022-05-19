
`ifndef TEMPLATE_SLAVE_AGENT_SVH
`define TEMPLATE_SLAVE_AGENT_SVH

class template_slave_agent extends uvm_agent;

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Public interface (Component users may manipulate these fields/methods)
  //
  //////////////////////////////////////////////////////////////////////////////
  template_config cfg;

  // The following are the verification components that make up
  // this agent
  template_slave_driver driver;
  template_slave_sequencer sequencer;
  template_slave_monitor monitor;
  virtual template_if vif;

  // USER: Add your fields here

  // This macro performs UVM object creation, type control manipulation, and 
  // factory registration
  `uvm_component_utils_begin(template_slave_agent)
    // USER: Register your fields here
  `uvm_component_utils_end

  // new - constructor
  extern function new (string name, uvm_component parent);

  // uvm build phase
  extern function void build();
  
  // uvm connection phase
  extern function void connect();

  // This method assigns the virtual interfaces to the agent's children
  extern function void assign_vi(virtual template_if vif);

  //////////////////////////////////////////////////////////////////////////////
  //
  //  Implementation (private) interface
  //
  //////////////////////////////////////////////////////////////////////////////


endclass : template_slave_agent

`endif // TEMPLATE_SLAVE_AGENT_SVH

