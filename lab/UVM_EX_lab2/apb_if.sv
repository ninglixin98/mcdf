
`ifndef APB_IF_SV
`define APB_IF_SV

interface apb_if (input clk, input rstn);

  logic [31:0] paddr;
  logic        pwrite;
  logic        psel;
  logic        penable;
  logic [31:0] pwdata;
  logic [31:0] prdata;

  // Control flags
  bit                has_checks = 1;
  bit                has_coverage = 1;

  // Actual Signals 
  // USER: Add interface signals

  clocking cb_mst @(posedge clk);
    // USER: Add clocking block detail
    default input #1ps output #1ps;
    output paddr, pwrite, psel, penable, pwdata;
    input prdata;
  endclocking : cb_mst

  clocking cb_slv @(posedge clk);
   // USER: Add clocking block detail
    default input #1ps output #1ps;
    input paddr, pwrite, psel, penable, pwdata;
    output prdata;
  endclocking : cb_slv

  clocking cb_mon @(posedge clk);
   // USER: Add clocking block detail
    default input #1ps output #1ps;
    input paddr, pwrite, psel, penable, pwdata, prdata;
  endclocking : cb_mon

  // Coverage and assertions to be implemented here.
  // USER: Add assertions/coverage here
  property psel_paddr;
	@(posedge clk) psel |-> !$isunknown(paddr);
  endproperty
  assert property(psel_paddr) else `uvm_error("ASSERT", "paddr is unknown");
  
  property psel_penable;
    @(posedge clk) $rose(psel) |=> $rose(penable);
  endproperty
  assert property(psel_penable) else `uvm_error("ASSERT", "penable is not rose");
  
  property penable_check;
    @(posedge clk) $rose(penable) |=> $fell(penable);
  endproperty
  assert property(penable_check) else `uvm_error("ASSERT", "penable is not rose for one clk");
  
  property pwdata_stable_check;//
    @(posedge clk) if(pwrite) psel |=> $stable(pwdata);
  endproperty
  assert property(pwdata_stable_check) else `uvm_error("ASSERT", "pwdata is unstable");
  
  property paddr_pwrite_stable_check;
    @(posedge clk) !psel |-> $stable(paddr) |-> $stable(pwrite);
  endproperty
  assert property(paddr_pwrite_stable_check) else `uvm_error("ASSERT", "paddr and pwrite has changed");
  
  property prdata_check;
    @(posedge clk) if(!pwrite) penable |-> !$isunknown(prdata);
  endproperty
  assert property(prdata_check) else `uvm_error("ASSERT", "read data error");
  
  property burst_write;
    @(posedge clk) if(pwrite) $fell(penable) |-> $stable(psel);
  endproperty
  cover property(burst_write);
  
  property burst_read;
    @(posedge clk) if(!pwrite) $fell(penable) |-> $stable(psel);
  endproperty
  cover property(burst_read);
     
  property single_write;
    @(posedge clk) if(pwrite) $fell(penable) |-> $fell(psel);
  endproperty
  cover property(single_write);
  
  property single_read;
    @(posedge clk) if(!pwrite) $fell(penable) |-> $fell(psel);
  endproperty
  cover property(single_read);
  
  property burst_write_read;
    @(posedge clk) if($stable(paddr)) pwrite[*2] |=> !pwrite[*2];//
  endproperty
  cover property(burst_write_read);
  
  property write_write;
    @(posedge clk) if($stable(paddr)) psel throughout pwrite[*4] |=> !pwrite[*2];//
  endproperty
  cover property(write_write);
  
  property read_write_read;
    @(posedge clk) if($stable(paddr)) psel throughout !pwrite[*2] |=> pwrite[*2] |=> !pwrite[*2];
  endproperty
  cover property(read_write_read);
  
  // APB command covergroup
  covergroup cg_apb_command @(posedge clk iff rstn);
    pwrite: coverpoint pwrite{
      type_option.weight = 0;
      bins write = {1};
      bins read  = {0};

    }
    psel : coverpoint psel{
      type_option.weight = 0;
      bins sel   = {1};
      bins unsel = {0};
    }
    cmd  : cross pwrite, psel{
      bins cmd_write = binsof(psel.sel) && binsof(pwrite.write);
      bins cmd_read  = binsof(psel.sel) && binsof(pwrite.read);
      bins cmd_idle  = binsof(psel.unsel);
    }
  endgroup: cg_apb_command

  // APB transaction timing group
  covergroup cg_apb_trans_timing_group @(posedge clk iff rstn);
    psel: coverpoint psel{
      bins single   = (0 => 1 => 1  => 0); 
      bins burst_2  = (0 => 1 [*4]  => 0); 
      bins burst_4  = (0 => 1 [*8]  => 0); 
      bins burst_8  = (0 => 1 [*16] => 0); 
      bins burst_16 = (0 => 1 [*32] => 0); 
      bins burst_32 = (0 => 1 [*64] => 0); 
    }
    penable: coverpoint penable {
      bins single = (0 => 1 => 0 [*2:10] => 1);
      bins burst  = (0 => 1 => 0         => 1);
    }
  endgroup: cg_apb_trans_timing_group

  // APB write & read order group
  covergroup cg_apb_write_read_order_group @(posedge clk iff (rstn && penable));
    write_read_order: coverpoint pwrite{
      bins write_write = (1 => 1);
      bins write_read  = (1 => 0);
      bins read_write  = (0 => 1);
      bins read_read   = (0 => 0);
    } 
  endgroup: cg_apb_write_read_order_group

  initial begin : coverage_control
    if(has_coverage) begin
      automatic cg_apb_command cg0 = new();
      automatic cg_apb_trans_timing_group cg1 = new();
      automatic cg_apb_write_read_order_group cg2 = new();
    end
  end

  // PROPERY ASSERTION
  property p_paddr_no_x;
    @(posedge clk) psel |-> !$isunknown(paddr);
  endproperty: p_paddr_no_x
  assert property(p_paddr_no_x) else `uvm_error("ASSERT", "PADDR is unknown when PSEL is high")

  // TODO

  // PROPERTY COVERAGE
  property p_write_during_nonburst_trans;
    @(posedge clk) $rose(penable) |-> pwrite throughout (##1 (!penable)[*2] ##1 penable[=1]);
  endproperty: p_write_during_nonburst_trans
  cover property(p_write_during_nonburst_trans);

  // TODO


  initial begin: assertion_control
    fork
      forever begin
        wait(rstn == 0);
        $assertoff();
        wait(rstn == 1);
        $asserton();
      end
    join_none
  end

endinterface : apb_if

`endif // APB_IF_SV
