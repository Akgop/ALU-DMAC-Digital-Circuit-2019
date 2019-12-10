module ALU_calculation(clk, state, opcode, opA, opB, shamt, result, wr_en_result,
	mul_start, multiplicand, multiplier, mul_result, mul_done, muldone_clear);
	
	input mul_done, clk;
	input [1:0] shamt;
	input [3:0] state, opcode;
	input [31:0] opA, opB;
	input [63:0] mul_result;
	
	output reg wr_en_result, muldone_clear;
	output reg mul_start;
	output reg [31:0] result, multiplicand, multiplier;
	
	wire [63:0] not_a, not_b, w_and, w_or, w_xor, w_xnor, w_add, w_sub;
	wire [63:0] lsl_a, lsr_a, asr_a, lsl_b, lsr_b, asr_b;
	reg [63:0] opA_s, opB_s, temp, w_mul;
	
	
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
	
	
	//////////// sign extension A //////////////
	always @ (opA) begin
		if(opA[31] == 1'b1) opA_s <= {32'hffff_ffff, opA};
		else opA_s <= {32'h0, opA};
	end
	
	//////////// sign extension B //////////////
	always @ (opB) begin
		if(opB[31] == 1'b1) opB_s <= {32'hffff_ffff, opB};
		else opB_s <= {32'h0, opB};
	end
	
	/////////// Generate mul signals ////////////
	always @ (state or opcode or opA or opB) begin
		if(opcode == 4'hf && state == MUL) begin  //if MUL
			mul_start <= 1'b1;
			multiplicand <= opA;
			multiplier <= opB;
		end
		else begin
			mul_start <= 0;
			multiplicand <= 0;
			multiplier <= 0;
		end
	end
	
	////////////// calculation ////////////////
	_NOT U1_NOT_A(opA_s, not_a);
	_NOT U2_NOT_B(opB_s, not_b);
	_AND U3_AND(opA_s, opB_s, w_and);
	_OR U4_OR(opA_s, opB_s, w_or);
	_XOR U5_XOR(opA_s, opB_s, w_xor);
	_XNOR U6_XNOR(opA_s, opB_s, w_xnor);
	LSL U7_LSL_A(opA_s, lsl_a, shamt);
	LSR U8_LSR_A(opA_s, lsr_a, shamt);
	ASR U9_ASR_A(opA_s, asr_a, shamt);
	LSL U10_LSL_B(opB_s, lsl_b, shamt);
	LSR U11_LSR_B(opB_s, lsr_b, shamt);
	ASR U12_ASR_B(opB_s, asr_b, shamt);
	CLA U13_ADD(.a(opA_s), .b(opB_s), .ci(1'b0), .s(w_add), .co());
	CLA U14_SUB(.a(opA_s), .b(not_b), .ci(1'b1), .s(w_sub), .co());
	
	//////////// get w_mul /////////////
	always @ (mul_done or mul_result) begin
		if(mul_done == 1'b1) w_mul <= mul_result;
		else w_mul <= 0;
	end
	
	always @ (posedge clk) begin
		if(mul_done == 1'b1) begin
			temp <= w_mul;
		end
		else if(state == 4'h2 || state == 4'h3) begin
			case(opcode)
				4'h1: temp <= not_a;
				4'h2: temp <= not_b;
				4'h3: temp <= w_and;
				4'h4: temp <= w_or;
				4'h5: temp <= w_xor;
				4'h6: temp <= w_xnor;
				4'h7: temp <= lsl_a;
				4'h8: temp <= lsr_a;
				4'h9: temp <= asr_a;
				4'ha: temp <= lsl_b;
				4'hb: temp <= lsr_b;
				4'hc: temp <= asr_b;
				4'hd: temp <= w_add;
				4'he: temp <= w_sub;
				//4'hf: temp <= w_mul;
				default: temp <= 0;
			endcase
		end
		else begin
			temp <= temp;
		end
	end
	
	
	
	
	////////////// output logic /////////////
	always @ (state or temp or mul_done) begin
		case(state)
			RESULT_PUSH1: begin
				wr_en_result <= 1'b1;
				result <= temp[63:32];
				muldone_clear <= 1'b0;
			end
			RESULT_PUSH2: begin
				wr_en_result <= 1'b1;
				result <= temp[31:0];
				if(mul_done == 1'b1) muldone_clear <= 1'b1;
				else muldone_clear <= 1'b0;
			end
			default: begin
				wr_en_result <= 0;
				result <= 0;
				muldone_clear <= 1'b0;
			end
		endcase
	end
endmodule

















