class packet;
	integer i = 1;
	function new(int val);
		i = val + 1;
	endfunction
	function shift();
		i = i << 1;
	endfunction
endclass

class linkedpacked extends packet;
	integer i = 3;
	function new(int val);
		super.new(val);
		if(val >= 2)
			i = val;
	endfunction
	function shift();
		super.shift();
		i = i << 2;
	endfunction
endclass

module tb;
	initial begin
		packet p = new(3);
		linkedpacked lp = new(1);
		//packet tmp;
		//tmp = lp;
		$display("p.i = %0d", p.i);
		$display("lp.i = %0d", lp.i);//同名情况下，父类和子类的i不相同，是各自独立的
		p.shift();
		$display("after shift, p.i = %0d", p.i);
		lp.shift();
		$display("after shift, lp.i = %0d", lp.i);
		//$display("tmp.i = %0d", tmp.i);
	end
endmodule

		
