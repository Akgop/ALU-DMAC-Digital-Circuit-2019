module Top(clk, reset_n, m0_req, m0_wr, m0_addr, m0_dout, a_interrupt, d_interrupt,
	m0_grant, m_din);
	
	
	input clk, reset_n, m0_req, m0_wr;
	input [15:0] m0_addr;
	input [31:0] m0_dout;
	output a_interrupt, d_interrupt, m0_grant;
	output [31:0] m_din;
	
	wire s0_sel, s1_sel, s2_sel, s3_sel, s4_sel, s_wr;
	wire m1_grant, m1_req, m1_wr;
	wire [15:0] s_addr; 
	wire [15:0] m1_addr;
	wire [31:0] s_din, s0_dout, s1_dout, s2_dout, s3_dout, s4_dout;
	wire [31:0] m1_dout;
 	
	////////// BUS ///////////
	BUS U0_BUS(.clk(clk), .reset_n(reset_n), .m0_req(m0_req), .m0_wr(m0_wr), 
		.m0_addr(m0_addr), .m0_dout(m0_dout), .m0_grant(m0_grant),
		.m1_req(m1_req), .m1_wr(m1_wr), .m1_addr(m1_addr), .m1_dout(m1_dout), .m1_grant(m1_grant), .m_din(m_din),
		.s0_dout(s0_dout), .s1_dout(s1_dout), .s2_dout(s2_dout), .s3_dout(s3_dout), .s4_dout(s4_dout),
		.s0_sel(s0_sel), .s1_sel(s1_sel), .s2_sel(s2_sel), .s3_sel(s3_sel), .s4_sel(s4_sel),
		.s_addr(s_addr), .s_wr(s_wr), .s_din(s_din));
	
	////////// RAM #1 (OPERAND) ///////////
	ram U1_ram1(.clk(clk), .cen(s2_sel), .wen(s_wr), .addr(s_addr), .din(s_din), .dout(s2_dout));
	
	////////// RAM #2 (INSTRUCTION) ///////////
	ram U2_ram2(.clk(clk), .cen(s3_sel), .wen(s_wr), .addr(s_addr), .din(s_din), .dout(s3_dout));
	
	////////// RAM #3 (RESULT) ///////////
	ram U3_ram3(.clk(clk), .cen(s4_sel), .wen(s_wr), .addr(s_addr), .din(s_din), .dout(s4_dout));
	
	////////// DMAC ///////////////
	DMAC_Top U4_DMAC(.clk(clk), .reset_n(reset_n), .m_grant(m1_grant), .m_din(m_din), 
		.s_sel(s0_sel), .s_wr(s_wr), .s_addr(s_addr), .s_din(s_din),
		.m_req(m1_req), .m_wr(m1_wr), .m_addr(m1_addr), .m_dout(m1_dout), 
		.s_dout(s0_dout), .s_interrupt(d_interrupt));
		
	////////// ALU ///////////////
	ALU_Top U5_ALU(.clk(clk), .reset_n(reset_n), .s_sel(s1_sel), .s_wr(s_wr), 
		.s_addr(s_addr), .s_din(s_din), .s_dout(s1_dout), .s_interrupt(a_interrupt));
	
	
endmodule
