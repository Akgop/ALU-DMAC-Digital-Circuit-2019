module DMAC_FIFO(clk, reset_n, rd_en, wr_en, src_addr_in, src_addr_out,
	dest_addr_in, dest_addr_out, data_size_in, data_size_out,
	rd_ack, wr_err, rd_err);
	
	input clk, reset_n, rd_en;
	input wr_en;
	input [31:0] src_addr_in, dest_addr_in, data_size_in;
	output wr_err, rd_err, rd_ack;
	output [31:0] src_addr_out, dest_addr_out, data_size_out;
	
	wire src_rd_ack, src_rd_err, src_wr_ack, src_wr_err,
		des_rd_ack, des_rd_err, des_wr_ack, des_wr_err,
		siz_rd_ack, siz_rd_err, siz_wr_ack, siz_wr_err;
	wire [4:0] data_count1, data_count2, data_count3;
	reg [2:0] to_fifo;
		
	//DMAC FIFO - capacity 16
	FIFO16 U1_src_addr(.clk(clk), .reset_n(reset_n), .rd_en(rd_en), .wr_en(wr_en), 
		.din(src_addr_in), .dout(src_addr_out), .data_count(data_count1), 
		.rd_ack(src_rd_ack), .rd_err(src_rd_err), .wr_ack(src_wr_ack), .wr_err(src_wr_err));
		
	//DMAC FIFO - capacity 16
	FIFO16 U2_dest_addr(.clk(clk), .reset_n(reset_n), .rd_en(rd_en), .wr_en(wr_en), 
		.din(dest_addr_in), .dout(dest_addr_out), .data_count(data_count2), 
		.rd_ack(des_rd_ack), .rd_err(des_rd_err), .wr_ack(des_wr_ack), .wr_err(des_wr_err));
		
	//DMAC FIFO - capacity 16
	FIFO16 U3_data_size(.clk(clk), .reset_n(reset_n), .rd_en(rd_en), .wr_en(wr_en), 
		.din(data_size_in), .dout(data_size_out), .data_count(data_count3), 
		.rd_ack(siz_rd_ack), .rd_err(siz_rd_err), .wr_ack(siz_wr_ack), .wr_err(siz_wr_err));
	
	//Generate WR_ERR
	assign wr_err = src_wr_err | des_wr_err | siz_wr_err;
	//Generate RD_ERR
	assign rd_err = src_rd_err | des_rd_err | siz_rd_err; 
	//Generate RD_ACK
	assign rd_ack = src_rd_ack & des_rd_ack & siz_rd_ack;
endmodule