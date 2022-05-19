class repeat_tb;
	int i = 10;
	task run();
		int i = 10;
		repeat(i) begin
			$display("repeat started");
			i = i + 1;
		end
	endtask
endclass

module repeat_tb1;
	initial begin
	repeat_tb rp = new();
	rp.run();
	end
endmodule