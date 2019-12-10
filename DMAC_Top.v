module DMAC_Top(clk, reset_n, m_grant, m_din,
	s_sel, s_wr, s_addr, s_din,
	m_req, m_wr, m_addr, m_dout, s_dout, s_interrupt);
	
	input clk, reset_n, m_grant, s_sel, s_wr;
	input [15:0] s_addr;
	input [31:0] m_din, s_din;
	output m_req, m_wr, s_interrupt;
	output [15:0] m_addr;
	output [31:0] m_dout, s_dout;
	
	wire op_start, opdone_clear, wr_en, rd_en, rd_ack, wr_err, rd_err;
	wire [1:0] op_mode, status;
	wire [31:0] src_to_fifo, des_to_fifo, siz_to_fifo;
	wire [31:0] src_from_fifo, des_from_fifo, siz_from_fifo;
	
	//////////////////// DMAC SLAVE //////////////////////////
	DMAC_SLAVE U0_SLAVE(.clk(clk), .reset_n(reset_n), .s_sel(s_sel), .s_wr(s_wr), 
		.s_addr(s_addr), .s_din(s_din),
		.s_dout(s_dout), .s_interrupt(s_interrupt), 
		.op_start(op_start), .status(status), 
		.op_mode(op_mode), .opdone_clear(opdone_clear),
		.src_addr(src_to_fifo), .dest_addr(des_to_fifo), .data_size(siz_to_fifo), .wr_en(wr_en));
	
	//////////////////// DMAC FIFO //////////////////////////
	DMAC_FIFO U1_FIFO(.clk(clk), .reset_n(reset_n), .rd_en(rd_en), .wr_en(wr_en), 
		.src_addr_in(src_to_fifo), .src_addr_out(src_from_fifo),
		.dest_addr_in(des_to_fifo), .dest_addr_out(des_from_fifo), 
		.data_size_in(siz_to_fifo), .data_size_out(siz_from_fifo),
		.rd_ack(rd_ack), .wr_err(wr_err), .rd_err(rd_err));
	
	//////////////////// DMAC MASTER //////////////////////////
	DMAC_MASTER U2_MASTER(.clk(clk), .reset_n(reset_n), 
		.op_start(op_start), .opdone_clear(opdone_clear), .op_mode(op_mode), 
		.rd_ack(rd_ack), .wr_err(wr_err), .rd_err(rd_err), 
		.data_size(siz_from_fifo), .src_addr(src_from_fifo), .dest_addr(des_from_fifo), 
		.rd_en(rd_en), .status(status), 
		.m_din(m_din), .m_grant(m_grant), .m_req(m_req), .m_wr(m_wr), .m_addr(m_addr), .m_dout(m_dout));

endmodule
