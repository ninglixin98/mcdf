`include "param_def.v"

package reg_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // register sequence item
  class reg_trans extends uvm_sequence_item;
    rand bit[7:0] addr;
    rand bit[1:0] cmd;
    rand bit[31:0] data;
    bit rsp;

    constraint cstr {
      soft cmd inside {`WRITE, `READ, `IDLE};
      soft addr inside {`SLV0_RW_ADDR, `SLV1_RW_ADDR, `SLV2_RW_ADDR, `SLV0_R_ADDR, `SLV1_R_ADDR, `SLV2_R_ADDR};
      addr[7:4]==0 && cmd==`WRITE -> soft data[31:6]==0;
      soft addr[7:5]==0;
      addr[4]==1 -> soft cmd == `READ;
    };

    `uvm_object_utils_begin(reg_trans)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(cmd, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(rsp, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name = "reg_trans");
      super.new(name);
    endfunction
  endclass

  // register driver
  class reg_driver extends uvm_driver #(reg_trans);
    local virtual reg_intf intf;
    mailbox #(reg_trans) req_mb;
    mailbox #(reg_trans) rsp_mb;

    `uvm_component_utils(reg_driver)
  
    function new (string name = "reg_driver", uvm_component parent);
      super.new(name, parent);
    endfunction
  
    function void set_interface(virtual reg_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run_phase(uvm_phase phase);
      fork
        this.do_drive();
        this.do_reset();
      join
    endtask

    task do_reset();
      forever begin
        @(negedge intf.rstn);
        intf.cmd_addr <= 0;
        intf.cmd <= `IDLE;
        intf.cmd_data_m2s <= 0;
      end
    endtask

    task do_drive();
      reg_trans req, rsp;
      @(posedge intf.rstn);
      forever begin
        this.req_mb.get(req);
        this.reg_write(req);
        void'($cast(rsp, req.clone()));
        rsp.rsp = 1;
        this.rsp_mb.put(rsp);
      end
    endtask
  
    task reg_write(reg_trans t);
      @(posedge intf.clk iff intf.rstn);
      case(t.cmd)
        `WRITE: begin 
                  intf.drv_ck.cmd_addr <= t.addr; 
                  intf.drv_ck.cmd <= t.cmd; 
                  intf.drv_ck.cmd_data_m2s <= t.data; 
                end
        `READ:  begin 
                  intf.drv_ck.cmd_addr <= t.addr; 
                  intf.drv_ck.cmd <= t.cmd; 
                  repeat(2) @(negedge intf.clk);
                  t.data = intf.cmd_data_s2m; 
                end
        `IDLE:  begin 
                  this.reg_idle(); 
                end
        default: $error("command %b is illegal", t.cmd);
      endcase
      `uvm_info(get_type_name(), $sformatf("sent addr %2x, cmd %2b, data %8x", t.addr, t.cmd, t.data), UVM_HIGH)
    endtask
    
    task reg_idle();
      @(posedge intf.clk);
      intf.drv_ck.cmd_addr <= 0;
      intf.drv_ck.cmd <= `IDLE;
      intf.drv_ck.cmd_data_m2s <= 0;
    endtask
  endclass

  // register generator and to be replaced by sequence + sequencer later
  class reg_generator extends uvm_component;
    rand bit[7:0] addr = -1;
    rand bit[1:0] cmd = -1;
    rand bit[31:0] data = -1;

    mailbox #(reg_trans) req_mb;
    mailbox #(reg_trans) rsp_mb;

    constraint cstr{
      soft addr == -1;
      soft cmd == -1;
      soft data == -1;
    }

    `uvm_component_utils_begin(reg_generator)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(cmd, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
    `uvm_component_utils_end

    function new (string name = "reg_generator", uvm_component parent);
      super.new(name, parent);
      this.req_mb = new();
      this.rsp_mb = new();
    endfunction

    task start();
      send_trans();
    endtask

    // generate transaction and put into local mailbox
    task send_trans();
      reg_trans req, rsp;
      req = new();
      assert(req.randomize with {local::addr >= 0 -> addr == local::addr;
                                 local::cmd >= 0 -> cmd == local::cmd;
                                 local::data >= 0 -> data == local::data;
                               })
        else $fatal("[RNDFAIL] register packet randomization failure!");
      `uvm_info(get_type_name(), req.sprint(), UVM_HIGH)
      this.req_mb.put(req);
      this.rsp_mb.get(rsp);
      `uvm_info(get_type_name(), rsp.sprint(), UVM_HIGH)
      if(req.cmd == `READ) 
        this.data = rsp.data;
      assert(rsp.rsp)
        else $error("[RSPERR] %0t error response received!", $time);
    endtask

    function void post_randomize();
      string s;
      s = {s, "AFTER RANDOMIZATION \n"};
      s = {s, "=======================================\n"};
      s = {s, "reg_generator object content is as below: \n"};
      s = {s, super.sprint()};
      s = {s, "=======================================\n"};
      `uvm_info(get_type_name(), s, UVM_HIGH)
    endfunction
  endclass

  // register monitor
  class reg_monitor extends uvm_monitor;
    local virtual reg_intf intf;
    //TODO-1.1 to implement uvm_blocking_put_PORT here and later to be
    //connected to target export/imp
    uvm_blocking_put_port #(reg_trans) mon_bp_port;

    `uvm_component_utils(reg_monitor)

    function new(string name="reg_monitor", uvm_component parent);
      super.new(name, parent);
      //TODO-1.1 instantiate the TLM port
      mon_bp_port = new("mon_bp_port", this);
    endfunction

    function void set_interface(virtual reg_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run_phase(uvm_phase phase);
      this.mon_trans();
    endtask

    task mon_trans();
      reg_trans m;
      forever begin
        @(posedge intf.clk iff (intf.rstn && intf.mon_ck.cmd != `IDLE));
        m = new();
        m.addr = intf.mon_ck.cmd_addr;
        m.cmd = intf.mon_ck.cmd;
        if(intf.mon_ck.cmd == `WRITE) begin
          m.data = intf.mon_ck.cmd_data_m2s;
        end
        else if(intf.mon_ck.cmd == `READ) begin
          @(posedge intf.clk);
          m.data = intf.mon_ck.cmd_data_s2m;
        end
        //TODO-1.1 to replace the mailbox with the TLM port
        mon_bp_port.put(m);
        `uvm_info(get_type_name(), $sformatf("monitored addr %2x, cmd %2b, data %8x", m.addr, m.cmd, m.data), UVM_HIGH)
      end
    endtask
  endclass: reg_monitor

  // register agent
  class reg_agent extends uvm_agent;
    reg_driver driver;
    reg_monitor monitor;
    local virtual reg_intf vif;

    `uvm_component_utils(reg_agent)

    function new(string name = "reg_agent", uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      driver = reg_driver::type_id::create("driver", this);
      monitor = reg_monitor::type_id::create("monitor", this);
    endfunction

    function void set_interface(virtual reg_intf vif);
      this.vif = vif;
      driver.set_interface(vif);
      monitor.set_interface(vif);
    endfunction
  endclass

endpackage
