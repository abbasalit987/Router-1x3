module router_fsm (clock, resetn, pkt_valid, data_in, fifo_full, fifo_empty_0,
		fifo_empty_1, fifo_empty_2, soft_reset_0, soft_reset_1, soft_reset_2,
		parity_done, low_pkt_valid, write_enb_reg, detect_add, ld_state, laf_state,
		lfd_state, full_state, rst_int_reg, busy);

//Input and Output declarations
	input clock,
		resetn,
		pkt_valid,
		fifo_full,
		fifo_empty_0,
		fifo_empty_1,
		fifo_empty_2,
		soft_reset_0,
		soft_reset_1,
		soft_reset_2,
		parity_done,
		low_pkt_valid;

	input [1:0] data_in;
	
	output write_enb_reg,
		detect_add,
		ld_state,
		laf_state,
		lfd_state,
		full_state,
		rst_int_reg,
		busy;

//parameter declarations for states in FSM
	parameter DECODE_ADDRESS = 3'b000,
		LOAD_FIRST_DATA = 3'b001,
		LOAD_DATA = 3'b010,
		LOAD_PARITY = 3'b011,
		FIFO_FULL_STATE = 3'b100,
		LOAD_AFTER_FULL = 3'b101,
		WAIT_TILL_EMPTY = 3'b110,
		CHECK_PARITY_ERROR = 3'b111;
	
	reg [1:0] temp;
	reg [2:0] present_state,next_state;
		
	always@(posedge clock)
		begin
			if(!resetn)
				temp <= 2'd0;
			else
				temp <= data_in;
		end

	always@(posedge clock)
		begin
			if(!resetn)
				present_state <= DECODE_ADDRESS;
			else if (((soft_reset_0) && (temp==2'b00)) || 
				((soft_reset_1) && (temp==2'b01)) || 
				((soft_reset_2) && (temp==2'b10)))
				present_state <= DECODE_ADDRESS;
			else 
				present_state <= next_state;
		end

	always@(*)
		begin
			case(present_state)
				DECODE_ADDRESS :
					begin
						if(((pkt_valid&(temp==0))&fifo_empty_0)|
						((pkt_valid&(temp==1))&fifo_empty_1)|
						((pkt_valid&(temp==2))&fifo_empty_2))
							next_state <= LOAD_FIRST_DATA;
						else if(((pkt_valid&(temp==0))&~fifo_empty_0)|
						((pkt_valid&(temp==1))&~fifo_empty_1)|
						((pkt_valid&(temp==2))&~fifo_empty_2))
							next_state <= WAIT_TILL_EMPTY;
						else 
							next_state <= DECODE_ADDRESS;
					end
				LOAD_FIRST_DATA :
					begin
						next_state <= LOAD_DATA;
					end
				LOAD_DATA :
					begin
						if(fifo_full)
							next_state <= FIFO_FULL_STATE;
						else if(!fifo_full && !pkt_valid)
							next_state <= LOAD_PARITY;
						else
							next_state <= LOAD_DATA;
					end
				LOAD_PARITY :
					begin
						next_state <= CHECK_PARITY_ERROR;
					end
				FIFO_FULL_STATE :
					begin
						if(fifo_full)
							next_state <= FIFO_FULL_STATE;
						else 
							next_state <= LOAD_AFTER_FULL;
					end
				LOAD_AFTER_FULL :
					begin
						if(!parity_done && low_pkt_valid)
							next_state<=LOAD_PARITY;
						else if(!parity_done && !low_pkt_valid)
							next_state<=LOAD_DATA;
						else 
							begin 
								if(parity_done==1'b1)
									next_state<=DECODE_ADDRESS;
								else
									next_state<=LOAD_AFTER_FULL;
							end
					end
				WAIT_TILL_EMPTY :
					begin
						if((fifo_empty_0 && (temp==0))||
						(fifo_empty_1 && (temp==1))||
						(fifo_empty_2 && (temp==2)))
							next_state <= LOAD_FIRST_DATA;
						else 
							next_state <= WAIT_TILL_EMPTY;
					end
				CHECK_PARITY_ERROR :
					begin
						if(fifo_full)
							next_state <= FIFO_FULL_STATE;
						else
							next_state <= DECODE_ADDRESS;
					end
			endcase
		end

	assign busy=((present_state==LOAD_FIRST_DATA)||(present_state==LOAD_PARITY)||
		(present_state==FIFO_FULL_STATE)||(present_state==LOAD_AFTER_FULL)||
		(present_state==WAIT_TILL_EMPTY)||(present_state==CHECK_PARITY_ERROR))?1:0;
	assign detect_add=((present_state==DECODE_ADDRESS))?1:0;
	assign lfd_state=((present_state==LOAD_FIRST_DATA))?1:0;
	assign ld_state=((present_state==LOAD_DATA))?1:0;
	assign write_enb_reg=((present_state==LOAD_DATA)||(present_state==LOAD_AFTER_FULL)||
		(present_state==LOAD_PARITY))?1:0;
	assign full_state=((present_state==FIFO_FULL_STATE))?1:0;
	assign laf_state=((present_state==LOAD_AFTER_FULL))?1:0;
	assign rst_int_reg=((present_state==CHECK_PARITY_ERROR))?1:0;

endmodule




