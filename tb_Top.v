`timescale 1ns/100ps

module tb_Top;
	
	reg clk, reset_n, m0_req, m0_wr;
	reg [15:0] m0_addr;
	reg [31:0] m0_dout;
	wire a_interrupt, d_interrupt, m0_grant;
	wire [31:0] m_din;
	
	Top U0_Top(clk, reset_n, m0_req, m0_wr, m0_addr, m0_dout, a_interrupt, d_interrupt,
		m0_grant, m_din);
		
	always #5 clk = ~clk;
	
	integer i;
	
	initial
	begin
				clk = 0; reset_n = 0; m0_req = 0; m0_wr = 0;
				m0_addr = 16'hffff; m0_dout = 32'h0;
		#3;	reset_n = 1;	m0_req = 1; m0_wr = 1;
		
		////////// Initialize RAM #2 INST //////////////
		#10;	m0_addr = 16'h0300; m0_dout = 32'h0000_216a;
		#10;	m0_addr = 16'h0301; m0_dout = 32'h0000_256a;
		#10;	m0_addr = 16'h0302; m0_dout = 32'h0000_316a;
		#10;	m0_addr = 16'h0303; m0_dout = 32'h0000_356a;
		#10;	m0_addr = 16'h0304; m0_dout = 32'h0000_396a;
		#10;	m0_addr = 16'h0305; m0_dout = 32'h0000_256a;
		#10;	m0_addr = 16'h0306; m0_dout = 32'h0000_3d6a;
		#10;	m0_addr = 16'h0307; m0_dout = 32'h0000_3d83;
		
		
		/////////// Initialize RAM #1 OPERAND ///////////////
		for(i = 0; i < 64; i = i+1) begin
			#10;	m0_addr = 16'h0200 + i; m0_dout = 32'h0000_0010 + i;
		end
		
		/////////// Push Descriptor to DMAC ////////////////
		#10;	m0_addr = 16'h0002; m0_dout = 32'h0000_0001;	//interrupt driven method
		//#10;	m0_addr = 16'h0002; m0_dout = 32'h0000_0000; //polling method
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0000_0300; //src		:RAM #2 INST
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0000_0103;	//dest	:ALU INST FIFO
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0000_0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0000_0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0000_0301; //src		:RAM #2 INST
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0000_0103;	//dest	:ALU INST FIFO
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0000_0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0000_0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0000_0302; //src		:RAM #2 INST
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0000_0103;	//dest	:ALU INST FIFO
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0000_0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0000_0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0000_0303; //src		:RAM #2 INST
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0000_0103;	//dest	:ALU INST FIFO
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0000_0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0000_0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0000_0304; //src		:RAM #2 INST
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0000_0103;	//dest	:ALU INST FIFO
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0000_0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0000_0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0000_0305; //src		:RAM #2 INST
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0000_0103;	//dest	:ALU INST FIFO
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0000_0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0000_0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0000_0306; //src		:RAM #2 INST
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0000_0103;	//dest	:ALU INST FIFO
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0000_0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0000_0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0000_0307; //src		:RAM #2 INST
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0000_0103;	//dest	:ALU INST FIFO
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0000_0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0000_0001;	//push descriptor
		
		//#10;	m0_addr = 16'h0007; m0_dout = 32'h0000_0001;	//opmode :linear, fixed
		//////////// OPERATION START //////////////
		#10;	m0_addr = 16'h0000; m0_dout = 32'h0001; 	m0_req = 0;	//DMAC -> Master
		
		while(d_interrupt != 1'b1) begin						//interrupt-driven method
		#10;
		end
		
		#10;	m0_addr = 16'h0001; m0_dout = 32'h0000; 	//DMAC interrupt clear
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0200;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0110;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0201;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0111;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0202;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0112;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0203;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0113;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0204;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0114;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0205;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0115;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0206;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0116;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0207;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0117;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0208;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0118;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0209;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0119;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h020a;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h011a;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h020b;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h011b;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h020c;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h011c;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h020d;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h011d;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h020e;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h011e;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h020f;	//src		:RAM #1 OPERAND
		#10;	m0_addr = 16'h0004; m0_dout = 32'h011f;	//dest	:ALU RF
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:16
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		//#10;	m0_addr = 16'h0007; m0_dout = 32'h0003;	//opmode :linear, linear
		//////////// OPERATION START //////////////
		#10;	m0_addr = 16'h0000; m0_dout = 32'h0001; 	m0_req = 0;	//DMAC -> Master
		while(d_interrupt != 1'b1) begin
		#10;
		end
		
		#10;	m0_addr = 16'h0001; m0_dout = 32'h0000;	//DMAC interrupt clear
		
		#10;	m0_addr = 16'h0102; m0_dout = 32'h0001;	//ALU interrupt-driven method
		#10;	m0_addr = 16'h0100; m0_dout = 32'h0001;	//ALU OPERATION START
		
		while(a_interrupt != 1'b1) begin
		#10;
		end
		
		#10;	m0_addr = 16'h0101; m0_dout = 32'h0000;	//ALU interrupt clear
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0400;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0401;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0402;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0403;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0404;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0405;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0406;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0407;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0408;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h0409;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h040a;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h040b;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h040c;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h040d;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h040e;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		#10;	m0_addr = 16'h0003; m0_dout = 32'h0104;	//src		:ALU RESULT FIFO
		#10;	m0_addr = 16'h0004; m0_dout = 32'h040f;	//dest	:RAM 3# RESULT
		#10;	m0_addr = 16'h0005; m0_dout = 32'h0001;	//size	:1
		#10;	m0_addr = 16'h0006; m0_dout = 32'h0001;	//push descriptor
		
		//#10;	m0_addr = 16'h0007; m0_dout = 32'h0002;	//opmode :fixed, linear
		//////////// OPERATION START //////////////
		#10;	m0_addr = 16'h0000; m0_dout = 32'h0001; 	m0_req = 0;	//DMAC -> Master
		
		while(d_interrupt != 1'b1) begin
		#10;
		end

		#10;	m0_addr = 16'h0001; m0_dout = 32'h0000;	//DMAC interrupt clear
		
		////////// DMAC REGISTER READ ///////////////
		#10;	m0_addr = 16'h0000; m0_wr = 0;
		#10;	m0_addr = 16'h0001;
		#10;	m0_addr = 16'h0002;
		#10;	m0_addr = 16'h0003;
		#10;	m0_addr = 16'h0004;
		#10;	m0_addr = 16'h0005;
		#10;	m0_addr = 16'h0006;
		#10;	m0_addr = 16'h0007;
		#10;	m0_addr = 16'h0008;
		
		
		//////////// ALU REGISTER READ //////////
		#10;	m0_addr = 16'h0100;
		#10;	m0_addr = 16'h0101;
		#10;	m0_addr = 16'h0102;
		#10;	m0_addr = 16'h0103;
		#10;	m0_addr = 16'h0105;
		
		#10;	m0_addr = 16'h0110;
		#10;	m0_addr = 16'h0111;
		#10;	m0_addr = 16'h0112;
		#10;	m0_addr = 16'h0113;
		#10;	m0_addr = 16'h0114;
		#10;	m0_addr = 16'h0115;
		#10;	m0_addr = 16'h0116;
		#10;	m0_addr = 16'h0117;
		#10;	m0_addr = 16'h0118;
		#10;	m0_addr = 16'h0119;
		#10;	m0_addr = 16'h011a;
		#10;	m0_addr = 16'h011b;
		#10;	m0_addr = 16'h011c;
		#10;	m0_addr = 16'h011d;
		#10;	m0_addr = 16'h011e;
		#10;	m0_addr = 16'h011f;
		
		
		
		
		#10;	$stop;
	end
endmodule
