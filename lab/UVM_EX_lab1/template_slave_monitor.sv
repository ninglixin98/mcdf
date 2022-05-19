
`ifndef TEMPLATE_SLAVE_MONITOR_SV
`define TEMPLATE_SLAVE_MONITOR_SV

function template_slave_monitor::new(string name, uvm_component parent=null);
  super.new(name, parent);
  trans_collected = new();
  item_collected_port = new("item_collected_port",this);
endfunction:new

// build
function void template_slave_monitor::build();
   super.build();
endfunction : build  


task template_slave_monitor::monitor_transactions();

   forever begin
 
      // Extract data from interface into transaction
      collect_transfer();

      // Check transaction
      if (checks_enable)
 	 perform_transfer_checks();

      // Update coverage
      if (coverage_enable)
 	 perform_transfer_coverage();

      // Publish to subscribers
      item_collected_port.write(trans_collected);

   end
endtask // monitor_transactions
   

task template_slave_monitor::run();
  fork
    monitor_transactions();
  join_none
endtask // run
  
task template_slave_monitor::collect_transfer();

  void'(this.begin_tr(trans_collected));
  // USER: Extract data and fill ata in template_transfer trans_collected

  // Advance clock
  @(vif.cb);

  // Wait for some start event..., indicate start of transaction
  void'(this.begin_tr(trans_collected));


  // Wait for some start event..., indicate end of transaction


  this.end_tr(trans_collected);
endtask // collect_transfer


// perform_transfer_checks
function void template_slave_monitor::perform_transfer_checks();

 // USER: do some checks on the transfer here

endfunction : perform_transfer_checks

// perform_transfer_coverage
function void template_slave_monitor::perform_transfer_coverage();

 // USER: coverage implementation

 -> template_slave_cov_transaction;

endfunction : perform_transfer_coverage

`endif // TEMPLATE_SLAVE_MONITOR_SV

