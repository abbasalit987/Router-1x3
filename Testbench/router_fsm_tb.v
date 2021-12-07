module router_fsm_tb();

	reg clock,resetn, pkt_valid;
	reg [1:0] data_in;
	reg fifo_full, fifo_empty_0, fifo_empty_1, fifo_empty_2, soft_reset_0, soft_reset_1, 
		soft_reset_2, parity_done, low_pkt_valid;
	wire write_enb_reg, detect_add, ld_state, laf_state, lfd_state, full_state, 
		rst_int_reg, busy;

	router_fsm DUT (.clock(clock),
			.resetn(resetn), 
			.pkt_valid(pkt_valid), 
			.data_in(data_in), 
			.fifo_full(fifo_full), 
			.fifo_empty_0(fifo_empty_0), 
			.fifo_empty_1(fifo_empty_1), 
			.fifo_empty_2(fifo_empty_2), 
			.soft_reset_0(soft_reset_0), 
			.soft_reset_1(soft_reset_1), 
			.soft_reset_2(soft_reset_2), 
			.parity_done(parity_done), 
			.low_pkt_valid(low_pkt_valid), 
			.write_enb_reg(write_enb_reg), 
			.detect_add(detect_add), 
			.ld_state(ld_state), 
			.laf_state(laf_state), 
			.lfd_state(lfd_state),
			.full_state(full_state), 
			.rst_int_reg(rst_int_reg), 
			.busy(busy));
	
	initial 
		begin
			clock = 1'b0;
			forever #5 clock=~clock;
		end
	
	task reset;
		begin
			resetn=1'b0;
			#10;
			resetn=1'b1;
		end
	endtask
	
	task task1;
		begin
			pkt_valid=1'b0; 
			data_in=2'b00;
			fifo_full=1'b0; 
			fifo_empty_0=1'b0;
			fifo_empty_1=1'b1; 
			fifo_empty_2=1'b1; 
			soft_reset_0=1'b1; 
			soft_reset_1=1'b0;
			soft_reset_2=1'b1;
			parity_done =1'b1;
			low_pkt_valid=1'b1;
		end
	endtask
	
	task task2;
		begin
			pkt_valid=1'b1; 
			data_in=2'b10;
			fifo_full=1'b0; 
			fifo_empty_0=1'b1;
			fifo_empty_1=1'b0; 
			fifo_empty_2=1'b1; 
			soft_reset_0=1'b0; 
			soft_reset_1=1'b1;
			soft_reset_2=1'b1;
			parity_done =1'b1;
			low_pkt_valid=1'b1;
		end
	endtask
	
	initial 
		begin
			reset;
			#20;
			task1;
			#40;
			task2;
			#40;
			reset;
			#100;
			$finish;
		end
		
	initial $monitor("Data In=%b Present State=%b Next State=%b",data_in,DUT.present_state,
			DUT.next_state);
endmodule
