module tb;
	class packet1;
	rand bit [7:0] x;
	constraint cstr {soft x == 5;}
	endclass
	
	class packet2;
	bit [7:0] x = 10;
	function int get_rand_x(input bit [7:0] x = 20);
		packet1 pkt = new();
		pkt.randomize() with {x == local::this.x;};
		return pkt.x;
	endfunction
	endclass
	
	initial begin
		packet2 pkt = new();
		$display("x = %0d",pkt.get_rand_x(30));
	end
endmodule
