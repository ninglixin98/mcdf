module tb2;
	semaphore mem_acc_key;
	
	int unsigned mem[int unsigned];
	
	task automatic write(int unsigned addr, int unsigned data);
		mem_acc_key.get();
		mem[addr] = data;
		mem_acc_key.put();
	endtask
	
	task automatic read(int unsigned addr, output int unsigned data);
		mem_acc_key.get();
		if (mem.exists(addr))
			data = mem[addr];
		else
			data = 'x;
		mem_acc_key.put();
	endtask
	
	initial begin
		int unsigned data = 100;
		mem_acc_key = new(1);
		forever begin
			fork begin
					#10ns;
					write('h10, data + 100);
					$display("@%t write data %d", $time, data);
				end
				
				begin
					#10ns
					read('h10, data);
					$display("@%t read data %d", $time, data);
				end
			join
		end
	end
endmodule
