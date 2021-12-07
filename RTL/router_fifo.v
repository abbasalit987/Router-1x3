module router_fifo(clock,resetn,soft_reset,write_enb,read_enb,lfd_state,data_in,full,empty,data_out);

//parameter declarations	
	parameter fifo_width = 8,
		fifo_depth = 16;

//Input and Output declarations 
	input clock, resetn, soft_reset, write_enb, read_enb, lfd_state;
	input [(fifo_width-1):0] data_in;
	output reg full, empty;
	output reg [(fifo_width-1):0] data_out;

//FIFO memory declaration 
	reg [fifo_width:0] fifo [fifo_depth-1:0];

	reg [3:0] rd_ptr, wr_ptr;
	reg [4:0] count,rw_count;
	reg temp;

	integer i;
	
	always@(posedge clock) //(load forst data)lfd_state block
		begin
			if(!resetn)
				temp <= 1'b0;
			else 
				temp <= lfd_state;
		end

	always@(posedge clock) //read and write (rw_count) block
		begin
			if(!resetn)
				rw_count <=0;
			else if ((write_enb && !full) && (read_enb && !empty))
				rw_count <= rw_count;
			else if (write_enb && !full)
				rw_count <= rw_count +1;
			else if (read_enb && !empty)
				rw_count <= rw_count -1;
			else 	
				rw_count <= rw_count;
		end
	
	always@(rw_count) //empty or full flag block
		begin 
			if (rw_count == 0)
				empty = 1'b1;
			else 
				empty = 1'b0;
			if (rw_count == (fifo_depth-1))
				full = 1'b1;
			else 
				full = 1'b0;
		end

	always@(posedge clock) //write block
		begin
			if(!resetn || soft_reset)
				begin
					for(i=0;i<fifo_depth;i=i+1)
						fifo[i]<=0;
				end
			else if(write_enb && !full)
				begin
					{fifo[wr_ptr][fifo_width],fifo[wr_ptr][fifo_width-1:0]}
						<= {temp,data_in};
				end
		end

	always@(posedge clock) //read block
		begin 
			if(!resetn)
				data_out <=8'd0;
			else if(soft_reset)
				data_out <=8'bz;

			else
				begin
					if(read_enb && !empty)
						data_out <= fifo[rd_ptr];
					else if(count == 0)
						data_out <= 8'bz;
				end
		end

	always@(posedge clock) //count load block
		begin
			if(read_enb && !empty)
				begin
					if(fifo[rd_ptr][fifo_width])
						count <= fifo[rd_ptr][fifo_width-1:2]+1'b1;
					else if(count!=0)
						count <= count - 1'b1;
				end
		end

	always@(posedge clock) //read write pointer block
		begin
			if(!resetn || soft_reset)
				begin
					wr_ptr = 0;
					rd_ptr = 0;
				end
			else 
				begin
					if (read_enb && !empty)
						rd_ptr = rd_ptr + 1'b1;
					if (write_enb && !full)
						wr_ptr = wr_ptr + 1'b1;
				end
		end

endmodule	

				