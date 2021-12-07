module router_reg(clock, resetn, pkt_valid, data_in, fifo_full, detect_add, ld_state, laf_state,
		full_state, lfd_state, rst_int_reg, error, parity_done, low_pkt_valid, dout);

//Input and Output declarations 	
	input clock,
		resetn,
		pkt_valid,
		fifo_full,
		detect_add,
		ld_state,
		laf_state,
		full_state,
		lfd_state,
		rst_int_reg;

	input [7:0] data_in;
		
	output reg error,
		parity_done,
		low_pkt_valid;

	output reg [7:0] dout;

// declarations of 4 internal registers
	reg [7:0] hold_header_byte, 
		fifo_full_state_byte,
		internal_parity_byte,
		packet_parity_byte;

	always@(posedge clock) //parity_done block
		begin
			if(!resetn)
				parity_done <= 1'b0;
			else 
				begin
					if(ld_state && !fifo_full && !pkt_valid)
						parity_done <= 1'b1;
					else if(laf_state && low_pkt_valid && !parity_done)
						parity_done <= 1'b1;
					else 
						begin
							if(detect_add)
								parity_done <= 1'b0;
						end
				end
		end

	always@(posedge clock) //low_pkt_valid block 
		begin
			if(!resetn)
				low_pkt_valid <= 1'b0;
			else 
				begin
					if(ld_state && !pkt_valid)
						low_pkt_valid <= 1'b1;
					if(rst_int_reg)
						low_pkt_valid <= 1'b0;
				end
		end

	always@(posedge clock) // dout block 
		begin
			if(!resetn)
				dout <= 8'd0;
			else 
				begin
					if(detect_add && pkt_valid)
						hold_header_byte <= data_in;
					else if(lfd_state)
						dout <= hold_header_byte;
					else if(ld_state && !fifo_full)
						dout <= data_in;
					else if(ld_state && fifo_full)
						fifo_full_state_byte <= data_in;
					else 
						begin
							if(laf_state)
								dout <= fifo_full_state_byte;
						end
				end
		end	

	always@(posedge clock) //internal parity block 
		begin
			if(!resetn)
				internal_parity_byte <= 8'd0;
			else if(lfd_state)
				internal_parity_byte <= internal_parity_byte ^ hold_header_byte;
			else if(ld_state && pkt_valid && !full_state)
				internal_parity_byte <= internal_parity_byte ^ data_in;
			else
				begin
					if(detect_add)
						internal_parity_byte <= 8'd0;
				end
		end

	always@(posedge clock) //packet parity block
		begin
			if(!resetn)
				packet_parity_byte <= 8'd0;
			else 
				begin
					if(!pkt_valid && ld_state)
						packet_parity_byte <= data_in;
				end
		end

	always@(posedge clock) //error checking block
		begin
			if(!resetn)
				error <= 1'b0;
			else 
				begin
					if(parity_done)
						begin
							if(internal_parity_byte!=packet_parity_byte)
								error <= 1'b1;
							else
								error <= 1'b0;
						end
				end
		end

endmodule
