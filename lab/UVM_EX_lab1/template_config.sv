
`ifndef TEMPLATE_CONFIG_SV
`define TEMPLATE_CONFIG_SV

class template_config extends uvm_object;

  `uvm_object_utils(template_config)

  // USER to specify the config items
  uvm_active_passive_enum  is_active = UVM_ACTIVE;
  
  function new (string name = "template_config");
    super.new(name);
  endfunction : new


endclass

`endif // TEMPLATE_CONFIG_SV
