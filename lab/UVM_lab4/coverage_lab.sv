
module coverage_lab;

class coverage;
  bit[2:0] a, b;
  covergroup cvg;
    cpa: coverpoint a {
	  bins a0 = {0};
	  bins a1 = {1};
	}
	cpb: coverpoint b {
	  bins b0to1 = {[0:1]};
	  bins b2to3 = {[2:3]};
	}
	cpaXcpb: cross cpa, cpb;
	aXb: cross a, b;
  endgroup
  
  function new();
    cvg = new();
  endfunction
endclass

initial begin
  automatic coverage c0 = new();
  #10ns;
  $finish();
end


endmodule
