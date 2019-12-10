module DMAC_MASTER(clk, reset_n, op_start, opdone_clear, op_mode, 
	rd_ack, wr_err, rd_err, data_size, src_addr, dest_addr, rd_en, status, 
	m_din, m_grant, m_req, m_wr, m_addr, m_dout);
	
	input clk, reset_n, m_grant, op_start, opdone_clear, rd_ack, wr_err, rd_err;
	input [1:0] op_mode;
	input [31:0] src_addr, dest_addr, data_size, m_din;
	output m_req, m_wr, rd_en;
	output [1:0] status;
	output [15:0] m_addr;
	output [31:0] m_dout;
	
	wire [2:0] state, next_state;
	wire [31:0] next_src, next_dest, next_data_size;
	wire [31:0] cur_src, cur_dest, cur_data_size;
	
	//ns logic
	MASTER_ns_logic U0_ns_logic(.op_start(op_start), .opdone_clear(opdone_clear), .state(state), .next_state(next_state),
		.data_size(cur_data_size), .rd_ack(rd_ack), .wr_err(wr_err), .rd_err(rd_err), .m_grant(m_grant));
		
	//des-operation
	desoperation U1_desop(.state(state), .next_state(next_state), .op_mode(op_mode), .src(src_addr), .dest(dest_addr), .size(data_size), 
		.status(status), .cur_src(cur_src), .cur_dest(cur_dest), .cur_size(cur_data_size), .next_src(next_src), 
		.next_dest(next_dest), .next_size(next_data_size), .rd_ack(rd_ack), .rd_en(rd_en));
	
	//sequential
	dff3_r U2_STATE(.clk(clk), .reset_n(reset_n), .d(next_state), .q(state));
	
	dff32_r U3_SOURCE(.clk(clk), .reset_n(reset_n), .d(next_src), .q(cur_src));
	
	dff32_r U4_DESTINATION(.clk(clk), .reset_n(reset_n), .d(next_dest), .q(cur_dest));
	
	dff32_r U5_DATA_SIZE(.clk(clk), .reset_n(reset_n), .d(next_data_size), .q(cur_data_size));
	
	//out logic
	MASTER_o_logic U6_o_logic(.state(state), .src(cur_src), .dest(cur_dest),
		.m_req(m_req), .m_wr(m_wr), .m_din(m_din), .m_addr(m_addr), .m_dout(m_dout));
	
endmodule

/////////////////// ns logic /////////////////////

module MASTER_ns_logic(op_start, opdone_clear, state, next_state,
		data_size, rd_ack, wr_err, rd_err, m_grant);
	
	input m_grant, op_start, opdone_clear, wr_err, rd_err, rd_ack;
	input [2:0] state;
	input [31:0] data_size;
	output reg [2:0] next_state;
	
	parameter IDLE = 3'b000;
	parameter POP = 3'b001;
	parameter BUS_REQ = 3'b010;
	parameter READ = 3'b011;
	parameter WRITE = 3'b100;
	parameter POP2 = 3'b101;
	parameter DONE = 3'b110;
	parameter FAULT = 3'b111;
	
	always @ (state or op_start or opdone_clear or m_grant or 
			rd_ack or wr_err or rd_err or data_size) begin
		if(wr_err == 1'b1) next_state <= FAULT;
		else begin
			case(state)
				IDLE:	begin
					if(op_start == 1'b1) next_state <= POP;
					else next_state <= IDLE;
				end
				POP: begin
					if(rd_err == 1'b1) next_state <= FAULT;
					else if(rd_ack == 1'b1) next_state <= BUS_REQ;
					else next_state <= POP;
				end
				BUS_REQ: begin
					if(m_grant == 1'b1) next_state <= READ;
					else next_state <= BUS_REQ;
				end
				READ: begin
					next_state <= WRITE;
				end
				WRITE: begin
					if(data_size != 32'b0) next_state <= READ;
					else next_state <= POP2;
				end
				POP2: begin
					if(rd_err == 1'b1) next_state <= DONE;
					else if(rd_ack == 1'b1) next_state <= READ;
					else next_state <= POP2;
				end
				DONE: begin
					if(opdone_clear == 1'b1) next_state <= IDLE;
					else next_state <= DONE;
				end
				FAULT: next_state <= FAULT;
				default: next_state <= 3'bx;
			endcase
		end
	end
endmodule



////////////////// desoperation ///////////////////////

module desoperation(state, next_state, op_mode, src, dest, size, status,
	cur_src, cur_dest, cur_size, next_src, next_dest, next_size, 
	rd_ack, rd_en);
	
	input rd_ack;
	input [1:0] op_mode;
	input [2:0] state, next_state;
	input [31:0] src, dest, size, cur_src, cur_dest, cur_size;
	output reg rd_en;
	output reg [1:0] status;
	output reg [31:0] next_src, next_dest, next_size;
	
	parameter IDLE = 3'b000;
	parameter POP = 3'b001;
	parameter BUS_REQ = 3'b010;
	parameter READ = 3'b011;
	parameter WRITE = 3'b100;
	parameter POP2 = 3'b101;
	parameter DONE = 3'b110;
	parameter FAULT = 3'b111;
	
	always @ (next_state) begin
		case(next_state)
			POP: rd_en <= 1'b1;
			POP2: rd_en <= 1'b1;
			default: rd_en <= 1'b0;
		endcase
	end
	
	always @ (next_state) begin
		case(next_state)
			IDLE: status <= 2'b00;
			POP: status <= 2'b01;
			BUS_REQ: status <= 2'b01;
			READ: status <= 2'b01;
			WRITE: status <= 2'b01;
			POP2: status <= 2'b01;
			DONE: status <= 2'b10;
			FAULT: status <= 2'b11;
			default: status <= 2'bx;
		endcase
	end
	
	always @ (state or next_state or src or dest or size or cur_dest or cur_size or cur_src or op_mode or rd_ack) begin
		if(rd_ack == 1'b1) begin
			next_src <= src;
			next_dest <= dest;
			next_size <= size;
		end
		else begin
			if(state == READ) begin
				if(op_mode[0] == 1'b1) next_src <= cur_src + 32'b1;
				else next_src <= cur_src;
				next_dest <= cur_dest;
				next_size <= cur_size - 32'b1;
			end
			else if(state == WRITE) begin
				if(op_mode[1] == 1'b1) next_dest <= cur_dest + 32'b1;
				else next_dest <= cur_dest;
				next_src <= cur_src;
				next_size <= cur_size;
			end
			else begin
				case(next_state)
					IDLE: begin
						next_dest <= 32'b0;
						next_size <= 32'b0;
						next_src <= 32'b0;
					end
					default: begin
						next_dest <= cur_dest;
						next_src <= cur_src;
						next_size <= cur_size;
					end
				endcase
			end
		end
	end
	
endmodule

////////////// output logic ////////////////////

module MASTER_o_logic(state, src, dest,
	m_req, m_wr, m_din, m_addr, m_dout);
	
	input [2:0] state;
	input [31:0] src, dest, m_din;
	output reg m_req, m_wr;
	output reg [15:0] m_addr;
	output reg [31:0] m_dout;
	
	parameter IDLE = 3'b000;
	parameter POP = 3'b001;
	parameter BUS_REQ = 3'b010;
	parameter READ = 3'b011;
	parameter WRITE = 3'b100;
	parameter POP2 = 3'b101;
	parameter DONE = 3'b110;
	parameter FAULT = 3'b111;
	
	always @ (state or src or dest or m_din or m_req or m_wr) begin
		case(state)
			IDLE: begin
				m_req <= 1'b0;
				m_wr <= 1'b0;
				m_addr <= 16'b0;
				m_dout <= 32'b0;
			end
			POP: begin
				m_req <= 1'b0;
				m_wr <= 1'b0;
				m_addr <= 16'b0;
				m_dout <= 32'b0;
			end
			BUS_REQ: begin
				m_req <= 1'b1;
				m_wr <= 1'b0;
				m_addr <= 16'b0;
				m_dout <= 32'b0;
			end
			READ: begin
				m_req <= 1'b1;
				m_wr <= 1'b0;
				m_addr <= src[15:0];
				m_dout <= 32'b0;
			end
			WRITE: begin
				m_req <= 1'b1;
				m_wr <= 1'b1;
				m_addr <= dest[15:0];
				m_dout <= m_din;
			end
			POP2: begin
				m_req <= 1'b1;
				m_wr <= 1'b0;
				m_addr <= 16'hFFFF;
				m_dout <= 32'b0;
			end
			DONE: begin
				m_req <= 1'b0;
				m_wr <= 1'b0;
				m_addr <= 16'b0;
				m_dout <= 32'b0;
			end
			FAULT: begin
				m_req <= 1'b0;
				m_wr <= 1'b0;
				m_addr <= 16'b0;
				m_dout <= 32'b0;
			end
			default: begin
				m_req <= 1'b0;
				m_wr <= 1'b0;
				m_addr <= 16'b0;
				m_dout <= 32'b0;
			end
		endcase
	end
endmodule
