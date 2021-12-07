module router_fifo_tb();

	parameter fifo_width = 8,
		fifo_depth = 16;
	parameter clock_cycle = 10;

	reg clock, resetn, soft_reset, write_enb, read_enb, lfd_state;
	reg [(fifo_width-1):0] data_in;
	wire full, empty;
	wire [(fifo_width-1):0] data_out;

	integer i;

	router_fifo DUT (.clock(clock),.resetn(resetn),.soft_reset(soft_reset),
			.write_enb(write_enb),.read_enb(read_enb),.lfd_state(lfd_state),
			.data_in(data_in),.full(full),.empty(empty),.data_out(data_out));

	initial 
		begin
			clock = 1'b0;
			forever #(clock_cycle/2) clock=~clock;
		end

	task reset();
		begin
			@(negedge clock);
			resetn = 1'b0;
			@(negedge clock);
			resetn = 1'b1;
		end
	endtask	
	
	task softreset();
		begin
			@(negedge clock);
			soft_reset = 1'b1;
			@(negedge clock);
			soft_reset =1'b0;
		end
	endtask		

	task stimulus(input reg[(fifo_width):2] x, input reg [1:0] y);
		begin
			@(negedge clock);
			data_in = {x[fifo_width-1:2],y};
			lfd_state = x[fifo_width];
		end
	endtask

	task write();
		begin
			@(negedge clock);
			write_enb <= 1'b1;
			read_enb <= 1'b0;
		end
	endtask

	task read();
		begin 	
			@(negedge clock);
			write_enb <= 1'b0;
			read_enb <= 1'b1;
		end
	endtask

	task delay(input i);
		begin
			#i;
		end
	endtask

	initial 
		begin
			reset;
			softreset;
			delay(10);
			write;
			stimulus(7'd70,2'd2);
			delay(10);
			for(i=0;i<7;i=i+1)
				begin
					stimulus(i+1,2'd2);
					delay(10);
				end
			read;
			delay(500);
			$finish;
		end

	initial $monitor("Data In = %h Data Out = %h",data_in,data_out);

endmodule
