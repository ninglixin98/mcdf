
`ifndef TEMPLATE_SLAVE_AGENT_SV
`define TEMPLATE_SLAVE_AGENT_SV

function template_slave_agent::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction : new


function void template_slave_agent::build();
  super.build();
  // get config
  if( !uvm_config_db#(template_config)::get(this,"","cfg", cfg)) begin
    `uvm_warning("GETCFG","cannot get config object from config DB")
     cfg = template_config::type_id::create("cfg");
  end
  // get virtual interface
  if( !uvm_config_db#(virtual template_if)::get(this,"","vif", vif)) begin
    `uvm_fatal("GETVIF","cannot get vif handle from config DB")
  end
  monitor = template_slave_monitor::type_id::create("monitor",this);
  monitor.cfg = cfg;
  if(is_active == UVM_ACTIVE) begin
    sequencer = template_slave_sequencer::type_id::create("sequencer",this);
    sequencer.cfg = cfg;
    driver = template_slave_driver::type_id::create("driver",this);
    driver.cfg = cfg;
  end
endfunction : build

function void template_slave_agent::connect();
  assign_vi(vif);
  if(is_active == UVM_ACTIVE) begin
    driver.seq_item_port.connect(sequencer.seq_item_export);       
  end
endfunction : connect

function void template_slave_agent::assign_vi(virtual template_if vif);
  monitor.vif = vif;
   if (is_active == UVM_ACTIVE) begin
      sequencer.vif = vif; 
      driver.vif = vif; 
    end
endfunction : assign_vi

`endif // TEMPLATE_SLAVE_AGENT_SV

