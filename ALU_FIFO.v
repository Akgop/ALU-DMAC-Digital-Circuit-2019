module ALU_FIFO(clk, reset_n, rd_en_inst, wr_en_inst,
	inst_in, inst_out, rd_ack_inst, wr_err_inst, rd_err_inst,
	rd_en_result, wr_en_result, result_in, 
	result_out, rd_ack_result, wr_err_result, rd_err_result);
	
	input clk, reset_n, rd_en_inst, wr_en_inst, rd_en_result, wr_en_result;
	input [31:0] inst_in, result_in;
	output rd_ack_inst, wr_err_inst, rd_err_inst,
			 rd_ack_result, wr_err_result, rd_err_result;
	output [31:0] inst_out, result_out;
	
	
	////////// INSTRUCTION FIFO //////////////
	FIFO8 U0_inst(.clk(clk), .reset_n(reset_n), 
		.rd_en(rd_en_inst), .wr_en(wr_en_inst), 
		.din(inst_in), .dout(inst_out), .data_count(),
		.rd_ack(rd_ack_inst), .rd_err(rd_err_inst), 
		.wr_ack(), .wr_err(wr_err_inst));
	
	
	////////// RESULT FIFO //////////////
	FIFO16 U1_result(.clk(clk), .reset_n(reset_n), 
		.rd_en(rd_en_result), .wr_en(wr_en_result), 
		.din(result_in), .dout(result_out), .data_count(),
		.rd_ack(rd_ack_result), .rd_err(rd_err_result), 
		.wr_ack(), .wr_err(wr_err_result));
	
endmodule
