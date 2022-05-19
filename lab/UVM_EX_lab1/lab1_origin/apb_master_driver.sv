
`ifndef APB_MASTER_DRIVER_SV
`define APB_MASTER_DRIVER_SV

function apb_master_driver::new (string name, uvm_component parent);
  super.new(name, parent);
endfunction : new

task apb_master_driver::run();
   fork
     get_and_drive();
     reset_signals();
   join_none
endtask : run

task apb_master_driver::get_and_drive();
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info(get_type_name(), "sequencer got next item", UVM_HIGH)
      drive_transfer(req);
	  void'($cast(rsp,req.clone()));
	  rsp.set_sequence_id(req.get_sequence_id());
      seq_item_port.item_done(rsp);
      `uvm_info(get_type_name(), "sequencer item_done_triggered", UVM_HIGH)  
    end
   
endtask : get_and_drive

task apb_master_driver::drive_transfer (apb_transfer trans);
  `uvm_info(get_type_name(), "drive_transfer", UVM_HIGH)
  // USER: Add implementation
	case(trans.trans_kind)
		WRITE: this.do_write(trans);
		READ: this.do_read(trans);
		IDLE: this.do_idle();
		default: `uvm_fatal("KINDWRONG","the trans kind do not exist")
	endcase
endtask : drive_transfer

task apb_master_driver::do_write(apb_transfer trans);
  `uvm_info(get_type_name(), "do_write ...", UVM_HIGH)
  // USER: Add implementation
  @(vif.cb_mst);
  vif.cb_mst.pwrite <= 1;
  vif.cb_mst.psel <= 1;
  vif.cb_mst.paddr <= trans.addr;
  vif.cb_mst.pwdata <= trans.data;
  @(vif.cb_mst);
  vif.cb_mst.penable <= 1;
  repeat(trans.idle_cycle) this.do_idle;
endtask:send_idle

task apb_master_driver::do_read(apb_transfer trans);
  `uvm_info(get_type_name(), "do_read ...", UVM_HIGH)
  // USER: Add implementation
  @(vif.cb_mst);
  vif.cb_mst.pwrite <= 0;
  vif.cb_mst.psel <= 1;
  vif.cb_mst.penable <= 0;
  vif.cb_mst.paddr <= trans.addr;
  @(vif.cb_mst);
  vif.cb_mst.penable <= 1;
  #100ps;
  trans.data <= vif.cb_mst.prdata;
  repeat(trans.idle_cycle) this.do_idle;
endtask:send_idle

task apb_master_driver::do_idle();
  `uvm_info(get_type_name(), "send_idle ...", UVM_HIGH)
  // USER: Add implementation
  @(vif.cb_mst);
  vif.cb_mst.pwdata <= 0;
  vif.cb_mst.penable <= 0;
  vif.cb_mst.psel <= 0;
endtask:send_idle

task apb_master_driver::reset_signals();
  `uvm_info(get_type_name(), "reset_signals ...", UVM_HIGH)
  // USER: Add implementation
  fork
	@(negedge vif.rstn) begin
	vif.cb_mst.pwrite <= 0;
	vif.cb_mst.psel <= 0;
	vif.cb_mst.penable <= 0;
	vif.cb_mst.paddr <= 0;
	vif.cb_mst.pwdata <= 0;
	vif.cb_mst.prdata <= 0;
	end
  join_none
endtask : reset_signals

`endif // APB_MASTER_DRIVER_SV
