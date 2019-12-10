module DMAC_SLAVE(clk, reset_n, s_sel, s_wr, s_addr, s_din,
		s_dout, s_interrupt, op_start, status, op_mode, opdone_clear,
		src_addr, dest_addr, data_size, wr_en);
	//DMAC SLAVE Module
	
	
	input clk, reset_n;
	input s_sel, s_wr;
	input [1:0] status;
	input [15:0] s_addr;
	input [31:0] s_din;
	output s_interrupt, op_start, opdone_clear, wr_en;
	output [1:0] op_mode;
	output [31:0] s_dout, src_addr, dest_addr, data_size;

	reg [7:0] to_reg;
	wire [31:0] OPERATION_START,
		INTERRUPT, INTERRUPT_ENABLE,
		SOURCE_ADDRESS, DESTINATION_ADDRESS,
		DATA_SIZE, DESCRIPTOR_PUSH, OPERATION_MODE,
		DMA_STATUS;
	reg [31:0] s_dout;
	
	always @ (s_sel or s_wr or s_addr[7:0]) begin
		if(s_sel == 1'b1 && s_wr == 1'b1) begin
			case(s_addr[7:0]) 
				8'h00: to_reg <= 8'b0000_0001;
				8'h01: to_reg <= 8'b0000_0010;
				8'h02: to_reg <= 8'b0000_0100;
				8'h03: to_reg <= 8'b0000_1000;
				8'h04: to_reg <= 8'b0001_0000;
				8'h05: to_reg <= 8'b0010_0000;
				8'h06: to_reg <= 8'b0100_0000;
				8'h07: to_reg <= 8'b1000_0000;
				default: to_reg <= 0;
			endcase
		end
		else to_reg <= 0;
	end
	
	dff32_r_en_c U0_OP_START(clk, reset_n, 
		to_reg[0], opdone_clear, {31'h0, s_din[0]}, OPERATION_START);

	dff32_r_en_en U1_INTERRPUT(clk, reset_n, 
		to_reg[1], status, {31'h0, s_din[0]}, INTERRUPT);
	
	dff32_r_en U2_INTERRUPT_EN(clk, reset_n, 
		to_reg[2], {31'h0, s_din[0]}, INTERRUPT_ENABLE);
	
	dff32_r_en U3_SRC_ADDR(clk, reset_n, 
		to_reg[3], {16'h0, s_din[15:0]}, SOURCE_ADDRESS);
	
	dff32_r_en U4_DEST_ADDR(clk, reset_n, 
		to_reg[4], {16'h0, s_din[15:0]}, DESTINATION_ADDRESS);
	
	dff32_r_en U5_DATA_SIZE(clk, reset_n, 
		to_reg[5], {27'h0, s_din[4:0]}, DATA_SIZE);
	
	dff32_r_en2 U6_DESC_PUSH(clk, reset_n,
		to_reg[6], {31'h0, s_din[0]}, DESCRIPTOR_PUSH);
	
	dff32_r_en U7_OPMODE(clk, reset_n, 
		to_reg[7], {30'h0, s_din[1:0]}, OPERATION_MODE);
		
	dff32_r U8_DMA_STATUS(clk, reset_n, {30'h0, status}, DMA_STATUS);
	
	
	//9-to-1MUX
	always @ (posedge clk) begin
		if(s_sel == 1'b1 && s_wr == 1'b0) begin
			case(s_addr[7:0])
				8'h00: s_dout <= OPERATION_START;
				8'h01: s_dout <= INTERRUPT;
				8'h02: s_dout <= INTERRUPT_ENABLE;
				8'h03: s_dout <= SOURCE_ADDRESS;
				8'h04: s_dout <= DESTINATION_ADDRESS;
				8'h05: s_dout <= DATA_SIZE;
				8'h06: s_dout <= DESCRIPTOR_PUSH;
				8'h07: s_dout <= OPERATION_MODE;
				8'h08: s_dout <= DMA_STATUS;
				default: s_dout <= 32'h0;		
			endcase
		end
		else begin
			s_dout <= 32'b0;
		end
	end
	
	//////////// interrupt //////////
	assign s_interrupt = INTERRUPT[0] & INTERRUPT_ENABLE[0];
	
	//////////// op_start & opdone_clear & op_mode /////////////
	assign op_start = OPERATION_START[0];
	assign opdone_clear = ~INTERRUPT[0];
	assign op_mode = OPERATION_MODE[1:0];
	
	///////////// to fifo ////////////////
	assign src_addr = SOURCE_ADDRESS;
	assign dest_addr = DESTINATION_ADDRESS;
	assign data_size = DATA_SIZE;
	assign wr_en = DESCRIPTOR_PUSH[0];
	
endmodule


