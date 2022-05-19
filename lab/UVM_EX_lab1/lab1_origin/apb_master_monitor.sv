
`ifndef APB_MASTER_MONITOR_SV
`define APB_MASTER_MONITOR_SV

function apb_master_monitor::new(string name, uvm_component parent=null);
  super.new(name, parent);
  item_collected_port = new("item_collected_port",this);
  trans_collected = new();
endfunction:new

// build
function void apb_master_monitor::build();
   super.build();
endfunction : build  

task apb_master_monitor::monitor_transactions();

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
endtask 
   

task apb_master_monitor::run();
  fork
    monitor_transactions();
  join_none
endtask // run
  
  
task apb_master_monitor::collect_transfer();
  apb_transfer t;
  @(vif.cb_mon);
  if(vif.cb_mst.psel == 1 && vif.cb_mst.penable == 0) begin
	case(vif.cb_mst.pwrite)
		1'b1: begin @(vif.mon_cb)
			  t.addr = vif.cb_mon.addr;
			  t.trans_kind = WRITE;
			  t.data = vif.cb_mon.pwdata;
			  end
		1'b0: begin @(vif.mon_cb)
			  t.addr = vif.cb_mon.addr;
			  t.trans_kind = READ;
			  t.data = vif.cb_mon.prdata;
			  end
		default: `uvm_fatal("KINDWRONG", "the cmd is wrong")
	endcase
	item_collected_port.write(t);
  end
endtask 


// perform_transfer_checks
function void apb_master_monitor::perform_transfer_checks();

 // USER: do some checks on the transfer here

endfunction : perform_transfer_checks

// perform_transfer_coverage
function void apb_master_monitor::perform_transfer_coverage();

 // USER: coverage implementation
  -> apb_master_cov_transaction;	

endfunction : perform_transfer_coverage

`endif // APB_MASTER_MONITOR_SV

