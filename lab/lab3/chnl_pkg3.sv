package chnl_pkg3;
  class chnl_trans;
    rand bit[31:0] data[];
    rand int ch_id;
    rand int pkt_id;
    rand int data_nidles;
    rand int pkt_nidles;
    bit rsp;
    local static int obj_id = 0;
    constraint cstr{
      data.size inside {[4:8]};
      foreach(data[i]) data[i] == 'hC000_0000 + (this.ch_id<<24) + (this.pkt_id<<8) + i;
      soft ch_id == 0;
      soft pkt_id == 0;
      data_nidles inside {[0:2]};
      pkt_nidles inside {[1:10]};
    };

    function new();
      this.obj_id++;
    endfunction

    function chnl_trans clone();
      chnl_trans c = new();
      c.data = this.data;
      c.ch_id = this.ch_id;
      c.pkt_id = this.pkt_id;
      c.data_nidles = this.data_nidles;
      c.pkt_nidles = this.pkt_nidles;
      c.rsp = this.rsp;
      return c;
    endfunction

    function string sprint();
      string s;
      s = {s, $sformatf("=======================================\n")};
      s = {s, $sformatf("chnl_trans object content is as below: \n")};
      s = {s, $sformatf("obj_id = %0d: \n", this.obj_id)};
      foreach(data[i]) s = {s, $sformatf("data[%0d] = %8x \n", i, this.data[i])};
      s = {s, $sformatf("ch_id = %0d: \n", this.ch_id)};
      s = {s, $sformatf("pkt_id = %0d: \n", this.pkt_id)};
      s = {s, $sformatf("data_nidles = %0d: \n", this.data_nidles)};
      s = {s, $sformatf("pkt_nidles = %0d: \n", this.pkt_nidles)};
      s = {s, $sformatf("rsp = %0d: \n", this.rsp)};
      s = {s, $sformatf("=======================================\n")};
      return s;
    endfunction
  endclass: chnl_trans
  
  class chnl_initiator;
    local string name;
    local virtual chnl_intf intf;
    mailbox #(chnl_trans) req_mb;
    mailbox #(chnl_trans) rsp_mb;
  
    function new(string name = "chnl_initiator");
      this.name = name;
    endfunction
  
    function void set_interface(virtual chnl_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task run();
      this.drive();
    endtask

    task drive();
      chnl_trans req, rsp;
      @(posedge intf.rstn);
      forever begin
        this.req_mb.get(req);
        this.chnl_write(req);
        rsp = req.clone();
        rsp.rsp = 1;
        this.rsp_mb.put(rsp);
      end
    endtask
  
    task chnl_write(input chnl_trans t);
      foreach(t.data[i]) begin
        @(posedge intf.clk);
        intf.drv_ck.ch_valid <= 1;
        intf.drv_ck.ch_data <= t.data[i];
        wait(intf.ch_ready === 'b1);
        $display("%0t channel initiator [%s] sent data %x", $time, name, t.data[i]);
        repeat(t.data_nidles) chnl_idle();
      end
      repeat(t.pkt_nidles) chnl_idle();
    endtask
    
    task chnl_idle();
      @(posedge intf.clk);
      intf.drv_ck.ch_valid <= 0;
      intf.drv_ck.ch_data <= 0;
    endtask
  endclass: chnl_initiator
  
  class chnl_generator;
    rand int pkt_id = -1;
    rand int ch_id = -1;
    rand int data_nidles = -1;
    rand int pkt_nidles = -1;
    rand int data_size = -1;
    rand int ntrans = 10;

    mailbox #(chnl_trans) req_mb;
    mailbox #(chnl_trans) rsp_mb;

    constraint cstr{
      soft ch_id == -1;
      soft pkt_id == -1;
      soft data_size == -1;
      soft data_nidles == -1;
      soft pkt_nidles == -1;
      soft ntrans == 10;
    }

    function new();
      this.req_mb = new();
      this.rsp_mb = new();
    endfunction

    task run();
      repeat(ntrans) send_trans();
    endtask

    // generate transaction and put into local mailbox
    task send_trans();
      chnl_trans req, rsp;
      req = new();
      assert(req.randomize with {local::ch_id >= 0 -> ch_id == local::ch_id; 
                                 local::pkt_id >= 0 -> pkt_id == local::pkt_id;
                                 local::data_nidles >= 0 -> data_nidles == local::data_nidles;
                                 local::pkt_nidles >= 0 -> pkt_nidles == local::pkt_nidles;
                                 local::data_size >0 -> data.size() == local::data_size; 
                               })
        else $fatal("[RNDFAIL] channel packet randomization failure!");
      this.pkt_id++;
      $display(req.sprint());
      this.req_mb.put(req);
      this.rsp_mb.get(rsp);
      $display(rsp.sprint());
      assert(rsp.rsp)
        else $error("[RSPERR] %0t error response received!", $time);
    endtask

    function string sprint();
      string s;
      s = {s, $sformatf("=======================================\n")};
      s = {s, $sformatf("chnl_generator object content is as below: \n")};
      s = {s, $sformatf("ntrans = %0d: \n", this.ntrans)};
      s = {s, $sformatf("ch_id = %0d: \n", this.ch_id)};
      s = {s, $sformatf("pkt_id = %0d: \n", this.pkt_id)};
      s = {s, $sformatf("data_nidles = %0d: \n", this.data_nidles)};
      s = {s, $sformatf("pkt_nidles = %0d: \n", this.pkt_nidles)};
      s = {s, $sformatf("data_size = %0d: \n", this.data_size)};
      s = {s, $sformatf("=======================================\n")};
      return s;
    endfunction

    function void post_randomize();
      string s;
      s = {"AFTER RANDOMIZATION \n", this.sprint()};
      $display(s);
    endfunction
  endclass: chnl_generator

  typedef struct packed {
    bit[31:0] data;
    bit[1:0] id;
  } mon_data_t;

  class chnl_monitor;
    local string name;
    local virtual chnl_intf intf;
    mailbox #(mon_data_t) mon_mb;
    function new(string name="chnl_monitor");
      this.name = name;
    endfunction
    function void set_interface(virtual chnl_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction
    task run();
      this.mon_trans();
    endtask

    task mon_trans();
      mon_data_t m;
      forever begin
        @(posedge intf.clk iff (intf.mon_ck.ch_valid==='b1 && intf.mon_ck.ch_ready==='b1));
        // USER TODO 3.1
        // Put the data into the mon_mb and use $display() to print the stored
        // data value with monitor name
		m.data = intf.mon_ck.ch_data;
		m.id = m.id + 1;
		mon_mb.put(m);
		$display("monitor name is %s, data value is %0d, id is %0d", name, m.data, m.id);
      end
    endtask
  endclass
  
  class mcdt_monitor;
    local string name;
    local virtual mcdt_intf intf;
    mailbox #(mon_data_t) mon_mb;
    function new(string name="mcdt_monitor");
      this.name = name;
    endfunction
    task run();
      this.mon_trans();
    endtask

    function void set_interface(virtual mcdt_intf intf);
      if(intf == null)
        $error("interface handle is NULL, please check if target interface has been intantiated");
      else
        this.intf = intf;
    endfunction

    task mon_trans();
      mon_data_t m;
      forever begin
        @(posedge intf.clk iff intf.mon_ck.mcdt_val==='b1);
        // USER TODO 3.1
        // Put the data into the mon_mb and use $display() to print the stored
        // data value with monitor name
		m.data = intf.mon_ck.mcdt_data;
		m.id = intf.mon_ck.mcdt_id;
		mon_mb.put(m);
		$display("monitor name is %s, data value is %0d, id is %0d", name, m.data, m.id);
      end
    endtask
  endclass

  class chnl_agent;
    local string name;
    chnl_initiator init;
    chnl_monitor mon;
    // USER TODO 3.2
    // Refer to how we create, set virtual interface and run the initiator
    // object, use do the similar action to the monitor object
    virtual chnl_intf vif;
    function new(string name = "chnl_agent");
      this.name = name;
      this.init = new({name, ".init"});
	  this.mon = new({name, ".mon"});
    endfunction

    function void set_interface(virtual chnl_intf vif);
      this.vif = vif;
      init.set_interface(vif);
	  mon.set_interface(vif);
    endfunction
    task run();
      fork
        init.run();
		mon.run();
      join
    endtask
  endclass: chnl_agent

  class chnl_checker;
    local string name;
    local int error_count;
    local int cmp_count;
    mailbox #(mon_data_t) in_mbs[3];
    mailbox #(mon_data_t) out_mb;

    function new(string name="chnl_checker");
      this.name = name;
      foreach(this.in_mbs[i]) this.in_mbs[i] = new();
      this.out_mb = new();
      this.error_count = 0;
      this.cmp_count = 0;
    endfunction

    task run();
      this.do_compare();
    endtask


    task do_compare();
      mon_data_t im, om;
      forever begin
        // USER TODO 3.3
        // compare data once there is data in in_mb0/in_mb1/in_mb2 and out_mb
        // first, get om from out_mb, and im from one of in_mbs
		this.out_mb.get(om);
		case(om.id)
			2'd0:this.in_mbs[0].get(im);
			2'd1:this.in_mbs[1].get(im);
			2'd2:this.in_mbs[2].get(im);
			default:$display("[CMPFAIL] Compared failed! Can not find channel id : %0d", om.id);
		endcase
        if(om.data != im.data) begin
          this.error_count++;
          $error("[CMPFAIL] Compared failed! mcdt out data %8x ch_id %0d is not equal with channel in data %8x", om.data, om.id, im.data);
        end
        else begin
          $display("[CMPSUCD] Compared succeeded! mcdt out data %8x ch_id %0d is not equal with channel in data %8x", om.data, om.id, im.data);
        end
        this.cmp_count++;
      end
    endtask
  endclass

  // USER TODO 3.4
  // Create, set interface and run the object mcdt_mon and checker
  // and also connect the mailbox of checker and chnl_mon/mcdt_mon
  class chnl_root_test;
    chnl_generator gen[3];
    chnl_agent agents[3];
    mcdt_monitor mcdt_mon;
    chnl_checker chker;
    protected string name;

    function new(string name = "chnl_root_test");
      this.name = name;
	  this.mcdt_mon = new();
	  this.mcdt_mon.mon_mb = this.chker.out_mb;
	  this.chker = new();
      foreach(agents[i]) begin
        this.agents[i] = new($sformatf("chnl_agent%0d",i));
        this.gen[i] = new();
        // USER TODO 2.1
        // Connect the mailboxes handles of gen[i] and agents[i].init
        this.agents[i].init.req_mb = this.gen[i].req_mb;
        this.agents[i].init.rsp_mb = this.gen[i].rsp_mb;
		this.agents[i].mon.mon_mb = this.chker.in_mbs[i];
      end
      $display("%s instantiated and connected objects", this.name);
    endfunction

    virtual task run();
      $display($sformatf("*****************%s started********************", this.name));
      this.do_config();
      fork
        agents[0].run();
        agents[1].run();
        agents[2].run();
		mcdt_mon.run();
		chker.run();
      join_none
      fork
        gen[0].run();
        gen[1].run();
        gen[2].run();
      join
      $display($sformatf("*****************%s finished********************", this.name));
      // USER TODO 1.3
      // Please move the $finish statement from the test run task to generator
      // You woudl put it anywhere you like inside generator to stop test when
      // all transactions have been transfered
      $finish();
    endtask

    virtual function void set_interface(virtual chnl_intf ch0_vif 
                                        ,virtual chnl_intf ch1_vif 
                                        ,virtual chnl_intf ch2_vif 
                                        ,virtual mcdt_intf mcdt_vif
                                      );
      agents[0].set_interface(ch0_vif);
      agents[1].set_interface(ch1_vif);
      agents[2].set_interface(ch2_vif);
	  mcdt_mon.set_interface(mcdt_vif);
    endfunction

    virtual function void do_config();
    endfunction

  endclass

  class chnl_basic_test extends chnl_root_test;
    function new(string name = "chnl_basic_test");
      super.new(name);
    endfunction
    virtual function void do_config();
      super.do_config();
      assert(gen[0].randomize() with {ntrans==100; data_nidles==0; pkt_nidles==1; data_size==8;})
        else $fatal("[RNDFAIL] gen[0] randomization failure!");

      // USER TODO 2.2
      // To randomize gen[1] with
      // ntrans==50, data_nidles inside [1:2], pkt_nidles inside [3:5],
      // data_size == 6
	  assert(gen[1].randomize() with {ntrans == 50; data_nidles inside {[1:2]}; pkt_nidles inside {[3:5]}; data_size == 6;})
			else $fatal("[RNDFAIL] gen[1] randomization failure!");
      // USER TODO 2.3
      // ntrans==80, data_nidles inside [0:1], pkt_nidles inside [1:2],
      // data_size == 32
	  assert(gen[2].randomize() with {ntrans == 80; data_nidles inside {[0:1]}; pkt_nidles inside {[1:2]}; data_size == 32;})
			else $fatal("[RNDFAIL] gen[2] randomization failure!");
    endfunction
  endclass: chnl_basic_test

  // USER TODO 2.4
  // each channel send data packet number inside [80:100]
  // data_nidles == 0, pkt_nidles == 1, data_size inside {8, 16, 32}
  class chnl_burst_test extends chnl_root_test;
    function new(string name = "chnl_burst_test");
      super.new(name);
    endfunction
	virtual function void do_config();
		assert(gen[0].randomize() with {ntrans inside {[80:100]}; data_nidles == 0; pkt_nidles == 1; data_size inside {8, 16, 32};})
			else $fatal("[RNDFAIL] gen[0] randomization failure!");
		assert(gen[1].randomize() with {ntrans inside {[80:100]}; data_nidles == 0; pkt_nidles == 1; data_size inside {8, 16, 32};})
			else $fatal("[RNDFAIL] gen[1] randomization failure!");
		assert(gen[1].randomize() with {ntrans inside {[80:100]}; data_nidles == 0; pkt_nidles == 1; data_size inside {8, 16, 32};})
			else $fatal("[RNDFAIL] gen[2] randomization failure!");
	endfunction
  endclass: chnl_burst_test

  // USER TODO 2.5
  // keep channel sending out data packet with number, and please
  // let all of slave channels raising fifo_full (ready=0) at the same time
  // and then to stop the test
  class chnl_fifo_full_test extends chnl_root_test;
    function new(string name = "chnl_fifo_full_test");
      super.new(name);
    endfunction
	virtual function void do_config();
		assert(gen[0].randomize() with {ntrans inside {[1000:2000]}; data_nidles == 0; pkt_nidles == 1; data_size inside {8, 16, 32};})
			else $fatal("[RNDFAIL] gen[0] randomization failure!");
		assert(gen[1].randomize() with {ntrans inside {[1000:2000]}; data_nidles == 0; pkt_nidles == 1; data_size inside {8, 16, 32};})
			else $fatal("[RNDFAIL] gen[1] randomization failure!");
		assert(gen[1].randomize() with {ntrans inside {[1000:2000]}; data_nidles == 0; pkt_nidles == 1; data_size inside {8, 16, 32};})
			else $fatal("[RNDFAIL] gen[2] randomization failure!");
	endfunction
	
	virtual task run();
      $display($sformatf("*****************%s started********************", this.name));
      this.do_config();
      fork
        agents[0].run();
        agents[1].run();
        agents[2].run();
      join_none
      fork
        gen[0].run();
        gen[1].run();
        gen[2].run();
      join_none
	  fork
		wait(agents[0].vif.drv_ck.ch_ready == 0);
		wait(agents[1].vif.drv_ck.ch_ready == 0);
		wait(agents[2].vif.drv_ck.ch_ready == 0);
	  join
      $display($sformatf("*****************%s finished********************", this.name));
      // USER TODO 1.3
      // Please move the $finish statement from the test run task to generator
      // You woudl put it anywhere you like inside generator to stop test when
      // all transactions have been transfered
      $finish();
    endtask
  endclass: chnl_fifo_full_test

endpackage

