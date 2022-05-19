
`ifndef APB_IF_SV
`define APB_IF_SV

interface apb_if (input clk, input rstn);

  // Control flags
  bit                has_checks = 1;
  bit                has_coverage = 1;

  // Actual Signals 
  // USER: Add interface signals
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic pwrite;
  logic psel;
  logic penable;
  
  clocking cb_mst @(posedge clk);
   // USER: Add clocking block detail
   default input #1ps output #1ps;
   input prdata;
   output paddr, pwdata, pwrite, psel, penable;
  endclocking : cb_mst

  modport DUT ( input clk
		// USER: Add dut I/O
              );
  modport TB  ( clocking cb);


  // Coverage and assertions to be implemented here.
  // USER: Add assertions/coverage here

endinterface : apb_if

`endif // APB_IF_SV
