module tb3;
	mailbox #(int) mb;
	
	initial begin
		int data;
		mb = new(8);
		forever begin
			case($urandom()%2)
				0:begin
					data = $urandom_range(0,10);
					mb.put(data);
					$display("mb put data %0d", data);
				end
				1:begin
					if(mb.num() > 0) begin
						mb.get(data);
						$display("mb get data %0d", data);
					end
				end
			endcase
		end
	end			
endmodule
