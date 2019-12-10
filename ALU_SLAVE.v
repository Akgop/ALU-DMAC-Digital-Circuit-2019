module ALU_SLAVE(clk, reset_n, s_sel, s_wr, s_addr, s_din, s_dout, s_interrupt, 
	op_start, opdone_clear, status, result_pop, wr_en_inst, inst, result,
	rAddr, rData, wAddr, wData, we_rf, rd_ack_result);
	
	input clk, reset_n, s_sel, s_wr, rd_ack_result;
	input [1:0] status;
	input [15:0] s_addr;
	input [31:0] s_din, rData, result;
	output op_start, opdone_clear, s_interrupt;
	output [31:0] s_dout;
 	
	output reg wr_en_inst, result_pop, we_rf;
	output reg [3:0] rAddr, wAddr;
	output reg [31:0] wData, inst;
	
	wire [31:0] OPERATION_START, INTERRUPT,
		INTERRUPT_ENABLE, INSTRUCTION, ALU_STATUS;
	reg [31:0] s_dout_ff, result_temp;
	reg [4:0] to_reg;
	
	//////////// Address Decoder ////////// WRITE ENABLE
	always @ (s_sel or s_wr or s_addr[7:0]) begin
		if(s_sel == 1'b1 && s_wr == 1'b1) begin
			case(s_addr[7:0])
				8'h00: to_reg <= 5'b0_0001;
				8'h01: to_reg <= 5'b0_0010;
				8'h02: to_reg <= 5'b0_0100;
				8'h03: to_reg <= 5'b0_1000;
				8'h04: to_reg <= 5'b1_1000;
				default: to_reg <= 0;
			endcase
		end
		else to_reg <= 0;
	end
	
	dff32_r_en_c U0_OP_START(clk, reset_n, 
		to_reg[0], opdone_clear, {31'h0, s_din[0]}, OPERATION_START);
		
	dff32_r_en_en U1_INTERRUPT(clk, reset_n, 
		to_reg[1], status, {31'h0, s_din[0]}, INTERRUPT);
		
	dff32_r_en U2_INTERRUPT_EN(clk, reset_n, 
		to_reg[2], {31'h0, s_din[0]}, INTERRUPT_ENABLE);
	
	dff32_r_en U3_INSTRUCTION(clk, reset_n, 
		to_reg[3], s_din, INSTRUCTION);
	
	dff32_r U4_ALU_STATUS(clk, reset_n, {30'h0, status}, ALU_STATUS);
	
	/////////// 7-to-1 MUX //////////////
	always @ (posedge clk) begin
		if(s_sel == 1'b1 && s_wr == 1'b0) begin
			casex(s_addr[7:0]) 
				8'h00: s_dout_ff = OPERATION_START;
				8'h01: s_dout_ff = INTERRUPT;
				8'h02: s_dout_ff = INTERRUPT_ENABLE;
				8'h03: s_dout_ff = INSTRUCTION;
				8'h05: s_dout_ff = ALU_STATUS;
				8'h1x: s_dout_ff = rData;
				default: s_dout_ff = 0;
			endcase
		end
		else s_dout_ff <= 0;
	end
	
	assign s_dout = (rd_ack_result == 1'b1) ? result : s_dout_ff;
	
	
	
	
	////////// Data from result fifo ////////////
	always @ (s_sel, s_wr, s_addr[7:0], INTERRUPT[0]) begin
		if(s_sel == 1'b1 && s_wr == 1'b0 && s_addr[7:0] == 8'h04) begin
			result_pop <= 1'b1;
		end
		else result_pop <= 1'b0;
	end
	
	//////////// register file write & read ///////////////
	always @ (s_sel, s_wr, s_addr[7:0], s_din)begin
		if(s_sel == 1'b1 && s_addr[4] == 1'b1) begin //Register select
			if(s_wr == 1'b1) begin		//write
				we_rf <= 1'b1;
				wAddr <= s_addr[3:0];
				wData <= s_din;
				rAddr <= 0;
			end
			else begin
				we_rf <= 0;
				wAddr <= 0;
				wData <= 0;
				rAddr <= s_addr[3:0];
			end
		end
		else begin
			we_rf <= 0;
			wAddr <= 0;
			wData <= 0;
			rAddr <= 0;
		end
	end
		
	//////////// instruction push /////////////
	always @ (s_sel, s_wr, s_addr[7:0], status, s_din) begin
		if(s_sel == 1'b1 && s_wr == 1'b1 && s_addr[7:0] == 8'h03 && status == 2'b00) begin
			wr_en_inst <= 1'b1;
			inst <= s_din;
		end
		else begin
			wr_en_inst <= 1'b0;
			inst <= 0;
		end
	end
		
	//////////// interrupt //////////
	assign s_interrupt = INTERRUPT[0] & INTERRUPT_ENABLE[0];	
	
	//////////// op_start & opdone_clear /////////////
	assign op_start = OPERATION_START[0];
	assign opdone_clear = ~INTERRUPT[0];
	
endmodule
