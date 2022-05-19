
`ifndef TEMPLATE_SLAVE_DRIVER_SV
`define TEMPLATE_SLAVE_DRIVER_SV

function template_slave_driver::new (string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

task template_slave_driver::run();
   fork
     get_and_drive();
     reset_signals();
   join_none
endtask : run


task template_slave_driver::get_and_drive();
    uvm_sequence_item item;
    template_transfer t;

    forever begin
      
      seq_item_port.get_next_item(item);

      // debug
      `uvm_info(get_type_name(), "sequencer got next item", UVM_HIGH)

      $cast(t, item);
      drive_transfer(t);
      seq_item_port.item_done();

      // debug
      `uvm_info(get_type_name(), "sequencer item_done_triggered", UVM_HIGH)
      // Advance clock
      send_idle();    
    end
   
endtask : get_and_drive

task template_slave_driver::drive_transfer (template_transfer trans);
  `uvm_info(get_type_name(), "drive_transfer", UVM_HIGH)
  // USER: Add implementation  
endtask : drive_transfer

task template_slave_driver::send_idle();
  `uvm_info(get_type_name(), "send_idle ...", UVM_HIGH)
  // USER: Add implementation
  @(vif.cb);
endtask:send_idle

task template_slave_driver::reset_signals();
  `uvm_info(get_type_name(), "reset_signals ...", UVM_HIGH)
  // USER: Add implementation
endtask : reset_signals

`endif // TEMPLATE_SLAVE_DRIVER_SV
