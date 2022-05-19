`timescale 1ns/1ps
module tb;
	event e1,e2,e3;
	task automatic wait_event(event e, string name);
		$display("@%t start wait_event %s", $time, name);
		@e;
		$display("@%t finish wait_event %s", $time, name);
	endtask
	
	initial begin
		fork
			wait_event(e1, "e1");
			wait_event(e2, "e2");
			wait_event(e3, "e3");
		join
	end
		
	initial begin
		fork
			begin #10ns -> e1; end
			begin #20ns -> e2; end
			begin #30ns -> e3; end
		join
	end

endmodule
