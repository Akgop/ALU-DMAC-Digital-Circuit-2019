module ALU_EXEC(clk, reset_n, op_start, opdone_clear, status,
	rd_ack_inst, rd_err_inst, wr_err_inst, rd_err_result, wr_err_result,
	rd_en_inst, inst, opA_in, opB_in, result_to_fifo, wr_en_result,
	rd_en_rf, opAaddr, opBaddr);

	input clk, reset_n, op_start, opdone_clear,
			rd_ack_inst, rd_err_inst, wr_err_inst, rd_err_result, wr_err_result;
	input [31:0] inst, opA_in, opB_in;
	output rd_en_inst, wr_en_result, rd_en_rf;
	output [1:0] status;
	output [3:0] opAaddr, opBaddr;
	output [31:0] result_to_fifo;
	
	wire mul_done, mul_start, muldone_clear;
	wire [1:0] next_shamt, shamt;
	wire [3:0] state, next_state, next_opcode, opcode;
	wire [31:0] next_opA, next_opB, opA, opB, multiplicand, multiplier;
	wire [63:0] mul_result;


	//////////// ns_logic //////////////
	ALU_ns_logic U0_ns(.state(state), .next_state(next_state), .op_start(op_start), .opdone_clear(opdone_clear),
		.rd_ack_inst(rd_ack_inst), .rd_err_inst(rd_err_inst), .wr_err_inst(wr_err_inst),
		.rd_err_result(rd_err_result), .wr_err_result(wr_err_result),
		.opcode(next_opcode), .mul_done(mul_done));
	
	//////////// tokenized //////////////
	ALU_tokenize U1_tok(.next_state(next_state), .status(status), 
		.rd_en_inst(rd_en_inst), .rd_ack_inst(rd_ack_inst), .inst(inst), .opAaddr(opAaddr), .opBaddr(opBaddr),
		.opA(opA_in), .next_opA(next_opA), .opB(opB_in), .next_opB(next_opB), .rd_en_rf(rd_en_rf),
		.next_shamt(next_shamt), .next_opcode(next_opcode));
	
	//////////// dff //////////////
	dff4_r U2_state(.clk(clk), .reset_n(reset_n), .d(next_state), .q(state));
	dff4_r U3_opcode(.clk(clk), .reset_n(reset_n), .d(next_opcode), .q(opcode));
	dff32_r U4_opA(.clk(clk), .reset_n(reset_n), .d(next_opA), .q(opA));
	dff32_r U5_opB(.clk(clk), .reset_n(reset_n), .d(next_opB), .q(opB));
	dff2_r U6_shamt(.clk(clk), .reset_n(reset_n), .d(next_shamt), .q(shamt));
	
	//////////// calculate /////////////
	ALU_calculation U3_calculate(.clk(clk), .state(state), .opcode(opcode), .opA(opA), .opB(opB), .shamt(shamt), 
		.result(result_to_fifo), .wr_en_result(wr_en_result),
		.mul_start(mul_start), .multiplicand(multiplicand), .multiplier(multiplier), 
		.mul_result(mul_result), .mul_done(mul_done), .muldone_clear(muldone_clear));
		
	///////////// multiplier ///////////////
	ALU_multiplier U4_multiply(.clk(clk), .reset_n(reset_n), 
		.op_start(mul_start), .op_clear(muldone_clear), .multiplicand(multiplicand), 
		.multiplier(multiplier), .result(mul_result), .op_done(mul_done));	
		

endmodule

module ALU_ns_logic(state, next_state, op_start, opdone_clear,
	rd_ack_inst, rd_err_inst, wr_err_inst,
	rd_err_result, wr_err_result,
	opcode, mul_done);
	
	input op_start, opdone_clear,
		rd_ack_inst, rd_err_inst, wr_err_inst,
		rd_err_result, wr_err_result,
		mul_done;
	input [3:0] opcode;
	input [3:0] state;
	output reg [3:0] next_state;
	
	parameter IDLE = 4'h0;
	parameter INST_POP1 = 4'h1;
	parameter NOP = 4'h2;
	parameter EXEC = 4'h3;
	parameter MUL = 4'h4;
	parameter RESULT_PUSH1 = 4'h5;
	parameter RESULT_PUSH2 = 4'h6;
	parameter INST_POP2 = 4'h7;
	parameter EXEC_DONE = 4'h8;
	parameter FAULT = 4'h9;
	
	always @ (state, wr_err_inst, rd_err_result, rd_err_inst, rd_err_inst, 
		opcode, mul_done, wr_err_result, opdone_clear, op_start, rd_ack_inst) begin
		if(wr_err_inst == 1'b1 || rd_err_result == 1'b1) next_state <= FAULT;
		else begin
			case(state)
				IDLE: begin
					if(op_start == 1'b1) next_state <= INST_POP1;
					else next_state <= IDLE;
				end
				INST_POP1: begin
					if(rd_err_inst == 1'b1) next_state <= FAULT;
					else if(rd_ack_inst == 1'b1) begin 
						if(opcode == 4'h0) next_state <= NOP;
						else if(opcode != 4'hf) next_state <= EXEC;
						else if(opcode == 4'hf) next_state <= MUL;
						else next_state <= FAULT;
					end
					else next_state <= INST_POP1;
				end
				NOP: next_state <= INST_POP2;
				EXEC: next_state <= RESULT_PUSH1;
				MUL: begin
					if(mul_done == 1'b1) next_state <= RESULT_PUSH1;
					else next_state <= MUL;
				end
				RESULT_PUSH1: begin
					if(wr_err_result == 1'b1) next_state <= FAULT;
					else next_state <= RESULT_PUSH2;
				end
				RESULT_PUSH2: next_state <= INST_POP2;
				INST_POP2: begin
					if(rd_err_inst == 1'b1) next_state <= EXEC_DONE;
					else if(rd_ack_inst == 1'b1) begin 
						if(opcode == 4'h0) next_state <= NOP;
						else if(opcode != 4'hf) next_state <= EXEC;
						else if(opcode == 4'hf) next_state <= MUL;
						else next_state <= FAULT;
					end
					else next_state <= INST_POP2;
				end
				EXEC_DONE: begin
					if(opdone_clear == 1'b1) next_state <= IDLE;
					else next_state <= EXEC_DONE;
				end
				FAULT: next_state <= FAULT;
				default: next_state <= 4'bx;
			endcase
		end
	end
endmodule


module ALU_tokenize(next_state, status, 
	rd_en_inst, rd_ack_inst, inst, opAaddr, opBaddr,
	opA, next_opA, opB, next_opB, rd_en_rf,
	next_shamt, next_opcode);
	
	input rd_ack_inst;
	input [3:0] next_state;
	input [31:0] inst, opA, opB;
	output [3:0] opAaddr, opBaddr;
	output reg rd_en_inst, rd_en_rf;
	output reg [1:0] status, next_shamt;
	output reg [3:0] next_opcode;
	output reg [31:0]next_opA, next_opB;
	
	wire [1:0] shamt;
	wire [3:0] opcode;
		
	parameter IDLE = 4'h0;
	parameter INST_POP1 = 4'h1;
	parameter NOP = 4'h2;
	parameter EXEC = 4'h3;
	parameter MUL = 4'h4;
	parameter RESULT_PUSH1 = 4'h5;
	parameter RESULT_PUSH2 = 4'h6;
	parameter INST_POP2 = 4'h7;
	parameter EXEC_DONE = 4'h8;
	parameter FAULT = 4'h9;
	
	
	
	///////// status ///////////
	always @ (next_state) begin
		case(next_state)
			IDLE: status <= 2'b00;
			INST_POP1: status <= 2'b01;
			NOP: status <= 2'b01;
			EXEC: status <= 2'b01;
			MUL: status <= 2'b01;
			RESULT_PUSH1: status <= 2'b01;
			RESULT_PUSH2: status <= 2'b01;
			INST_POP2: status <= 2'b01;
			EXEC_DONE: status <= 2'b10;
			FAULT: status <= 2'b11;
			default: status <= 2'bx;
		endcase
	end
	
	////////// rd_en_inst ///////////
	always @ (next_state) begin
		case(next_state) 
			INST_POP1: rd_en_inst <= 1'b1;
			INST_POP2: rd_en_inst <= 1'b1;
			default: rd_en_inst <= 1'b0;
		endcase
	end
	
	/////////// rd_en_rf //////////////
	always @ (next_state) begin
		case(next_state)
			EXEC: rd_en_rf <= 1'b1;
			MUL: rd_en_rf <= 1'b1;
			default: rd_en_rf <= 1'b0;
		endcase
	end

	
	always @ (rd_ack_inst or opcode or opA or opB or shamt) begin
		if(rd_ack_inst == 1'b1) begin
			next_opcode <= opcode;
			next_opA <= opA;
			next_opB <= opB;
			next_shamt <= shamt;
		end
		else begin
			next_opcode <= 0;
			next_opA <= 0;
			next_opB <= 0;
			next_shamt <= 0;
		end
	end
	
	/////////// tokenized value /////////////
	assign opcode = inst[13:10];
	assign opAaddr = inst[9:6];
	assign opBaddr = inst[5:2];
	assign shamt = inst[1:0];
endmodule






