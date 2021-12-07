module router_sync(clock,resetn,detect_add,fifo_full,full_0,full_1,full_2,
			data_in,write_enb_reg,write_enb,empty_0,empty_1,empty_2,
			vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,
			soft_reset_0,soft_reset_1,soft_reset_2);

// Input and Output declarations 	
	input clock,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,
		read_enb_0,read_enb_1,read_enb_2;

	input [1:0] data_in;

	output reg [2:0] write_enb;

	output reg fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;

	output wire vld_out_0,vld_out_1,vld_out_2;

	reg [1:0] temp;
	reg [4:0] count0,count1,count2;

	always@(posedge clock)
		begin
			if(!resetn)
				temp<='d0;
			else if(detect_add)
				temp<=data_in;
		end

	always@(posedge clock) //fifo_full block
		begin
			case(temp)
				2'b00 : fifo_full = full_0;
				2'b01 : fifo_full = full_1;
				2'b10 : fifo_full = full_2;
				default : fifo_full = 0;
			endcase
		end

	always@(posedge clock) //write_enb block
		begin
			if(write_enb_reg)
				begin
					case(temp)
						2'b00 : write_enb = 3'b001;
						2'b01 : write_enb = 3'b010;
						2'b10 : write_enb = 3'b100;
						default : write_enb = 3'b000;
					endcase
				end
			else
				write_enb = 3'b000;
		end

	assign vld_out_0 = !empty_0;
	assign vld_out_1 = !empty_1;
	assign vld_out_2 = !empty_2;
	
// Soft Reset blocks for 3 FIFOs
	always@(posedge clock)
		begin
			if(!resetn)
				count0 <= 'd0;
			else if (vld_out_0)
				begin
					if(!read_enb_0)
						begin
							if(count0 == 5'd30)
								begin
									count0 <= 'd0;
									soft_reset_0 <= 1'b1;
								end
							else
								begin
									count0 <= count0+1'b1;
									soft_reset_0 <= 1'b0;
								end
						end
					else count0 <= 'd0;
				end
			else count0 <= 'd0;
		end

	always@(posedge clock)
		begin
			if(!resetn)
				count1 <= 'd0;
			else if (vld_out_1)
				begin
					if(!read_enb_1)
						begin
							if(count1 == 5'd30)
								begin
									count1 <= 'd0;
									soft_reset_1 <= 1'b1;
								end
							else
								begin
									count1 <= count1+1'b1;
									soft_reset_1 <= 1'b0;
								end
						end
					else count1 <= 'd0;
				end
			else count1 <= 'd0;
		end

	always@(posedge clock)
		begin
			if(!resetn)
				count2 <= 'd0;
			else if (vld_out_2)
				begin
					if(!read_enb_2)
						begin
							if(count2 == 5'd30)
								begin
									count2 <= 'd0;
									soft_reset_2 <= 1'b1;
								end
							else
								begin
									count2 <= count2+1'b1;
									soft_reset_2 <= 1'b0;
								end
						end
					else count2 <= 'd0;
				end
			else count2 <= 'd0;
		end

endmodule
