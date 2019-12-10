module ALU_Top(clk, reset_n, s_sel, s_wr, s_addr, s_din, s_dout, s_interrupt);

	input clk, reset_n, s_sel, s_wr;
	input [15:0] s_addr;
	input [31:0] s_din;
	output s_interrupt;
	output [31:0] s_dout;
	
	wire op_start, opdone_clear, wr_en_inst, we_rf, rd_en,
		  rd_en_inst, wr_en_result, rd_ack_inst, wr_err_inst, rd_err_inst,
		  wr_err_result, rd_err_result, rd_en_result, rd_ack_result;
	wire [1:0] status;
	wire [3:0] rAddr, rAddr1, rAddr2, wAddr, opAaddr, opBaddr;
	wire [31:0] inst_in, inst_out, result_in, result_out, rData, wData, opA, opB;
	

	//////////////// ALU SLAVE //////////////////
	ALU_SLAVE U0_slave(.clk(clk), .reset_n(reset_n), .s_sel(s_sel), .s_wr(s_wr), .s_addr(s_addr), .s_din(s_din), .s_dout(s_dout),
		.s_interrupt(s_interrupt), .op_start(op_start), .opdone_clear(opdone_clear), .status(status), 
		.result_pop(rd_en_result), .wr_en_inst(wr_en_inst), .inst(inst_in), .result(result_out),
		.rAddr(rAddr), .rData(rData), .wAddr(wAddr), .wData(wData), .we_rf(we_rf), .rd_ack_result(rd_ack_result));
	
	//////////////// ALU REGISTER FILE ////////////////////
	ALU_RF U1_rf(.clk(clk), .reset_n(reset_n), .wAddr(wAddr), .wData(wData), .we(we_rf),
		.rd_en(rd_en), .rAddr(rAddr), .rAddr1(opAaddr), .rAddr2(opBaddr), .rData(rData), .rData1(opA), .rData2(opB));
	
	//////////////// ALU FIFO /////////////////////
	ALU_FIFO U2_fifo(.clk(clk), .reset_n(reset_n), .rd_en_inst(rd_en_inst), .wr_en_inst(wr_en_inst),
		.inst_in(inst_in), .inst_out(inst_out), .rd_ack_inst(rd_ack_inst), .wr_err_inst(wr_err_inst), .rd_err_inst(rd_err_inst),
		.rd_en_result(rd_en_result), .wr_en_result(wr_en_result), .result_in(result_in), 
		.result_out(result_out), .rd_ack_result(rd_ack_result), 
		.wr_err_result(wr_err_result), .rd_err_result(rd_err_result));
	
	//////////////// ALU EXECUTION /////////////////////
	ALU_EXEC U3_exec(.clk(clk), .reset_n(reset_n), .op_start(op_start), .opdone_clear(opdone_clear), .status(status),
		.rd_ack_inst(rd_ack_inst), .rd_err_inst(rd_err_inst), .wr_err_inst(wr_err_inst), 
		.rd_err_result(rd_err_result), .wr_err_result(wr_err_result),
		.rd_en_inst(rd_en_inst), .inst(inst_out), .opA_in(opA), .opB_in(opB), 
		.result_to_fifo(result_in), .wr_en_result(wr_en_result),
		.rd_en_rf(rd_en), .opAaddr(opAaddr), .opBaddr(opBaddr));

endmodule
