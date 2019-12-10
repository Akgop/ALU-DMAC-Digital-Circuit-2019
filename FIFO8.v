module FIFO8(clk, reset_n, rd_en, wr_en, din, dout, data_count,
		rd_ack, rd_err, wr_ack, wr_err);
	
	//Capacity 8 FIFO
	input clk, reset_n, rd_en, wr_en;
	input [31:0] din;
	output rd_ack, rd_err, wr_ack, wr_err;
	output [31:0] dout;
	output [3:0] data_count;
	
	wire [2:0] state, next_state;
	wire [3:0] next_data_count;
	wire [2:0] head, next_head, tail, next_tail;
	wire re, we;
	
	fifo8_ns U0_ns_logic(state, wr_en, rd_en, data_count, next_state);
	
	fifo8_cal_addr U1_address(.state(next_state), .data_count(data_count), 
		.head(head), .tail(tail), .next_data_count(next_data_count), 
		.next_head(next_head), .next_tail(next_tail), 
		.re(re), .we(we));
		
	//dff state
	dff3_r U2_STATE(.clk(clk), .reset_n(reset_n), 
		.d(next_state), .q(state));
	//dff data count
	dff4_r U3_DATA_COUNT(.clk(clk), .reset_n(reset_n), 
		.d(next_data_count), .q(data_count));
	//dff head pointer
	dff3_r U4_HEAD(.clk(clk), .reset_n(reset_n), 
		.d(next_head), .q(head));
	//dff tail pointer
	dff3_r U5_TAIL(.clk(clk), .reset_n(reset_n), 
		.d(next_tail), .q(tail));
		
	//register file
	Register_File8 U6_RF(.clk(clk), .reset_n(reset_n),
		.wAddr(tail), .wData(din), .we(we), .re(re), .rAddr(head), .rData(dout));
	
	//Output Logic - error signals
	fifo8_out U7_out(.state(state), .rd_ack(rd_ack), .rd_err(rd_err), 
		.wr_ack(wr_ack), .wr_err(wr_err));
endmodule

module Register_File8(clk, reset_n,
	wAddr, wData, we, re, rAddr, rData);
	
	input clk, reset_n, we, re;
	input [2:0] wAddr, rAddr; //3bit -> 8
	input [31:0] wData;
	output reg [31:0] rData;
	
	reg [31:0] mem [0:7];
	
	integer i;
	
	//initialize memory
	initial begin
		for(i=0; i<8; i=i+1) begin
			mem[i] = 32'b0;
		end
	end
	
	always @ (posedge clk or negedge reset_n) begin
		if(reset_n == 1'b0) begin
			mem[0] <= 32'b0; mem[1] <= 32'b0; mem[2] <= 32'b0;	mem[3] <= 32'b0;
			mem[4] <= 32'b0; mem[5] <= 32'b0; mem[6] <= 32'b0;	mem[7] <= 32'b0;
		end
		else if(re == 1'b1) begin	//READ
			rData <= mem[rAddr];
		end
		else if(we == 1'b1) begin //WRITE
			mem[wAddr] <= wData;
			rData <= 32'b0;
		end
		else begin
			rData <= 32'b0;
		end
	end
endmodule


module fifo8_ns(state, wr_en, rd_en, data_count, next_state);	//next state logic module
	input [2:0] state;	//3bit input state
	input wr_en, rd_en;	//1bit input we, re
	input [3:0] data_count;	//4bit input data count
	output reg [2:0] next_state;	//3bit output next state
	
	//Encoding State
	parameter INIT = 3'b000;
	parameter NO_OP = 3'b001;
	parameter WRITE = 3'b010;
	parameter WR_ERR = 3'b011;
	parameter READ = 3'b100;
	parameter RD_ERR = 3'b101;
	
	//when inputs changes
	always @ (state or wr_en or rd_en or data_count)
	begin
		case(state)
			INIT: begin	//INIT STATE transition
				if(wr_en == 1'b0 && rd_en == 1'b0) next_state <= NO_OP;	//wr_en, rd_en = 0 -> NO_OP
				else if(wr_en == 1'b1 && rd_en == 1'b1) next_state <= NO_OP;	//wr_en, rd_en = 1 -> NO_OP
				else if(wr_en == 1'b0 && rd_en == 1'b1 && data_count === 4'b0000) next_state <= RD_ERR;	//rd_en = 1, empty, RD_ERR
				else if(wr_en == 1'b0 && rd_en == 1'b1 && data_count !== 4'b0000) next_state <= READ;	//rd_en = 1, !empty, READ
				else if(wr_en == 1'b1 && rd_en == 1'b0 && data_count === 4'b1000) next_state <= WR_ERR;	//wr_en = 1, full, WR_ERR
				else if(wr_en == 1'b1 && rd_en == 1'b0 && data_count !== 4'b1000) next_state <= WRITE;	//wr_en = 1, !full, WRITE
				else next_state <= 3'bx;
			end
			NO_OP: begin	//NO_OP STATE transition
				if(wr_en == 1'b0 && rd_en == 1'b0) next_state <= NO_OP;	//wr_en, rd_en = 0 -> NO_OP
				else if(wr_en == 1'b1 && rd_en == 1'b1) next_state <= NO_OP;	//wr_en, rd_en = 1 -> NO_OP
				else if(wr_en == 1'b0 && rd_en == 1'b1 && data_count === 4'b0000) next_state <= RD_ERR;	//rd_en = 1, empty, RD_ERR
				else if(wr_en == 1'b0 && rd_en == 1'b1 && data_count !== 4'b0000) next_state <= READ;	//rd_en = 1, !empty, READ
				else if(wr_en == 1'b1 && rd_en == 1'b0 && data_count === 4'b1000) next_state <= WR_ERR;	//wr_en = 1, full, WR_ERR
				else if(wr_en == 1'b1 && rd_en == 1'b0 && data_count !== 4'b1000) next_state <= WRITE;	//wr_en = 1, !full, WRITE
				else next_state <= 3'bx;
			end
			WRITE: begin	//WRITE STATE transition
				if(wr_en == 1'b0 && rd_en == 1'b0) next_state <= NO_OP;	//wr_en, rd_en = 0 -> NO_OP
				else if(wr_en == 1'b1 && rd_en == 1'b1) next_state <= NO_OP;	//wr_en, rd_en = 1 -> NO_OP
				else if(wr_en == 1'b0 && rd_en == 1'b1) next_state <= READ;		//rd_en = 1 -> READ (count doesnt matter)
				else if(wr_en == 1'b1 && rd_en == 1'b0 && data_count === 4'b1000) next_state <= WR_ERR;	//wr_en = 1, full, WR_ERR
				else if(wr_en == 1'b1 && rd_en == 1'b0 && data_count !== 4'b1000) next_state <= WRITE;	//wr_en = 1, !full, WRITE
				else next_state <= 3'bx;
			end
			WR_ERR: begin	//WRITE ERROR STATE transition
				if(wr_en == 1'b0 && rd_en == 1'b0) next_state <= NO_OP;	//wr_en, rd_en = 0 -> NO_OP
				else if(wr_en == 1'b1 && rd_en == 1'b1) next_state <= NO_OP;	//wr_en, rd_en = 1 -> NO_OP
				else if(wr_en == 1'b0 && rd_en == 1'b1) next_state <= READ;		//rd_en = 1 -> READ
				else if(wr_en == 1'b1 && rd_en == 1'b0) next_state <= WR_ERR;	//wr_en = 1 -> WR_ERR
				else next_state <= 3'bx;
			end
			READ: begin		//READ STATE transition
				if(wr_en == 1'b0 && rd_en == 1'b0) next_state <= NO_OP;	//wr_en, rd_en = 0 -> NO_OP
				else if(wr_en == 1'b1 && rd_en == 1'b1) next_state <= NO_OP;	//wr_en, rd_en = 1 -> NO_OP
				else if(wr_en == 1'b0 && rd_en == 1'b1 && data_count === 4'b0000) next_state <= RD_ERR;	//rd_en = 1, empty, RD_ERR
				else if(wr_en == 1'b0 && rd_en == 1'b1 && data_count !== 4'b0000) next_state <= READ;	//rd_en = 1, !empty, READ
				else if(wr_en == 1'b1 && rd_en == 1'b0) next_state <= WRITE;	//wr_en = 1, WRITE
				else next_state <= 3'bx;
			end
			RD_ERR: begin	//READ ERROR STATE transition
				if(wr_en == 1'b0 && rd_en == 1'b0) next_state <= NO_OP;	//wr_en, rd_en = 0 -> NO_OP
				else if(wr_en == 1'b1 && rd_en == 1'b1) next_state <= NO_OP;	//wr_en, rd_en = 1 -> NO_OP
				else if(wr_en == 1'b0 && rd_en == 1'b1) next_state <= RD_ERR;	//rd_en = 1 -> RD_ERR
				else if(wr_en == 1'b1 && rd_en == 1'b0) next_state <= WRITE;	//wr_en = 1 -> WRITE
				else next_state <= 3'bx;
			end
			default: begin	//error handling
				next_state <= 3'bx;
			end
		endcase
	end
endmodule


module fifo8_cal_addr(state, data_count, head, tail, 
		next_data_count, next_head, next_tail, re, we);	//fifo_cal_addr Module
		
	input [2:0] state;	//3bit input state, head, tail
	input [2:0] head, tail;
	input [3:0] data_count;				//4bit input data_count
	output reg [2:0] next_head, next_tail;	//3bit output next head, tail
	output reg [3:0] next_data_count;	//4bit output next_data_count
	output reg re, we;	//1bit output read, write enable
	
	//global variable
	parameter INIT = 3'b000;
	parameter NO_OP = 3'b001;
	parameter WRITE = 3'b010;
	parameter WR_ERR = 3'b011;
	parameter READ = 3'b100;
	parameter RD_ERR = 3'b101;
	
	//when state~tail changes
	always @ (state or data_count or head or tail)
	begin
		case(state)
			INIT: begin	//state = 000
				next_data_count <= 4'b0000;	//everything = 0
				next_head <= 3'b000;
				next_tail <= 3'b000;
				re <= 1'b0;	we <= 1'b0;
			end
			NO_OP: begin	//state = 001
				next_data_count <= data_count;	//everything prev value
				next_head <= head;
				next_tail <= tail;
				re <= 1'b0;	we <= 1'b0;	//read, write enable signal = 0
			end
			WRITE: begin	//state = 010
				next_data_count <= data_count + 4'b0001;	//data count ++
				next_head <= head;
				next_tail <= tail + 3'b001;	//tail ++
				re <= 1'b0;	we <= 1'b1;	//write enable = 1
			end
			WR_ERR: begin	//state = 011
				next_data_count <= data_count;	//prev value
				next_head <= head;
				next_tail <= tail;
				re <= 1'b0;	we <= 1'b0;	//enable signals = 0 
			end
			READ: begin	//state = 100
				next_data_count <= data_count - 4'b0001;	//data count --
				next_head <= head + 3'b001;	//head ++
				next_tail <= tail;
				re <= 1'b1;	we <= 1'b0;	//read enable signal = 1
			end
			RD_ERR: begin	//state = 101
				next_data_count <= data_count;	//prev value
				next_head <= head;
				next_tail <= tail;
				re <= 1'b0;	we <= 1'b0;	//enable signals = 0 
			end
			default: begin	//error handling
				next_data_count <= 4'bx;
				next_head <= 3'bx;
				next_tail <= 3'bx;
				re <= 1'bx;	we <= 1'bx;
			end
		endcase
	end
endmodule


module fifo8_out(state, rd_ack, rd_err, wr_ack, wr_err);	//output logic module
	
	input [2:0] state;	//3bit state
	output reg wr_ack, wr_err, rd_ack, rd_err;
	
	//STATE Encoding
	parameter INIT = 3'b000;
	parameter NO_OP = 3'b001;
	parameter WRITE = 3'b010;
	parameter WR_ERR = 3'b011;
	parameter READ = 3'b100;
	parameter RD_ERR = 3'b101;
	
	always @ (state)	//when state changes
	begin
		case(state)		//control handshake signals
			INIT: begin	//INIT State outputs
				wr_ack=1'b0; wr_err=1'b0; rd_ack=1'b0; rd_err=1'b0;
			end
			NO_OP: begin	//NO_OP State outputs
				wr_ack=1'b0; wr_err=1'b0; rd_ack=1'b0; rd_err=1'b0;
			end
			WRITE: begin	//WRITE State outputs
				wr_ack=1'b1; wr_err=1'b0; rd_ack=1'b0; rd_err=1'b0;
			end
			WR_ERR: begin	//WR_ERR State outputs
				wr_ack=1'b0; wr_err=1'b1; rd_ack=1'b0; rd_err=1'b0;
			end
			READ: begin	//READ State outputs
				wr_ack=1'b0; wr_err=1'b0; rd_ack=1'b1; rd_err=1'b0;
			end
			RD_ERR: begin	//RD_ERR State outputs
				wr_ack=1'b0; wr_err=1'b0; rd_ack=1'b0; rd_err=1'b1;
			end
			default: begin	//error handling
				wr_ack=1'bx; wr_err=1'bx; rd_ack=1'bx; rd_err=1'bx;
			end
		endcase
	end
endmodule

