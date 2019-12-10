module BUS(clk, reset_n, m0_req, m0_wr, m0_addr, m0_dout, m0_grant,
			m1_req, m1_wr, m1_addr, m1_dout, m1_grant, m_din,
			s0_dout, s1_dout, s2_dout, s3_dout, s4_dout,
			s0_sel, s1_sel, s2_sel, s3_sel, s4_sel,
			s_addr, s_wr, s_din);
	//TOP_BUS module
	//Connect 5 Devices & 1 Testbench
	//inputs
	input clk, reset_n,
			m0_req, m0_wr, m1_req, m1_wr;
	input [15:0] m0_addr, m1_addr;
	input [31:0] m0_dout, m1_dout;
	input [31:0] s0_dout, s1_dout, s2_dout, s3_dout, s4_dout;
	//outputs
	output m0_grant, m1_grant, s_wr,
			s0_sel, s1_sel, s2_sel, s3_sel, s4_sel;
	output [15:0] s_addr;
	output [31:0] m_din, s_din;
	
	wire [4:0] sel_s_dout;
	
	//Arbiter
	Arbiter U0_Arbiter(.clk(clk), .reset_n(reset_n), 
			.M0_req(m0_req), .M1_req(m1_req), .M0_grant(m0_grant), .M1_grant(m1_grant));
	
	//select_wr_signal
	mux2 U1_wr(.d0(m0_wr), .d1(m1_wr), .s(m0_grant), .y(s_wr));
	
	//select_address
	mux2_16bits U2_address(.d0(m0_addr), .d1(m1_addr), .s(m0_grant), .y(s_addr));
	
	//select_s_din
	mux2_32bits U3_s_din(.d0(m0_dout), .d1(m1_dout), .s(m0_grant), .y(s_din));
	
	//address decoder
	Address_Decoder U4_Address_Decoder(.addr_in(s_addr), 
			.s0(s0_sel), .s1(s1_sel), .s2(s2_sel), .s3(s3_sel), .s4(s4_sel));
			
	//dff
	dff5_r U5_dff(.clk(clk), .reset_n(reset_n), 
			.d({s0_sel, s1_sel, s2_sel, s3_sel, s4_sel}), .q(sel_s_dout));
	
	//select_m_din
	mux5_32bits U6_m_din(.d0(s0_dout), .d1(s1_dout), 
			.d2(s2_dout), .d3(s3_dout), .d4(s4_dout), .s(sel_s_dout), .y(m_din));
		
endmodule



module Arbiter(clk, reset_n, M0_req, M1_req, M0_grant, M1_grant);
	//Arbiter = Select Master Logic
	input clk, reset_n;
	input M0_req, M1_req;
	output reg M0_grant, M1_grant;
	
	reg state, next_state;
	
	//encoding Master
	parameter M0 = 1'b0;
	parameter M1 = 1'b1;
	
	//ns_logic (Greedy Logic)
	always @ (M0_req or M1_req or state) begin
		case(state)
			M0: begin
				if(M0_req == 1'b1 || (M0_req == 1'b0 && M1_req == 1'b0))	//M0_req = 1 -> M0
					next_state <= M0;													//M0_req = 0, M1_req = 0 -> M0
				else if(M0_req == 1'b0 && M1_req == 1'b1)						//M0_req = 0, M1_req = 1 -> M1
					next_state <= M1;
				else next_state <= 1'bx;
			end
			M1: begin
				if(M1_req == 1'b1)	next_state <= M1;							//M1_req = 1 -> M1
				else if(M1_req == 1'b0) next_state <= M0;						//M1_req = 0 -> M0
				else next_state <= 1'bx;
			end
			default: next_state <= 1'bx;
		endcase
	end
	
	//sequential
	always @ (posedge clk or negedge reset_n) begin		//dff
		if(reset_n == 1'b0) state <= M0;
		else state <= next_state;
	end
	
	//o_logic
	always @ (state) begin
		case(state)
			M0: begin
				M0_grant = 1'b1;	M1_grant = 1'b0;	//M0 -> M0_grant = 1
			end
			M1: begin
				M0_grant = 1'b0;	M1_grant = 1'b1;	//M1 -> M1_grant = 1
			end
			default: begin
				M0_grant = 1'bx;	M1_grant = 1'bx;	//Error Handling
			end
		endcase
	end
	
endmodule


module Address_Decoder(addr_in, s0, s1, s2, s3, s4);	//Address Decoder
	input [15:0] addr_in;	//address
	output reg s0, s1, s2, s3, s4;	//s0~s5 select signal
	
	always @ (addr_in) begin
		if(addr_in[15:8] === 8'h00) begin	//base address = 00 
			s0 <= 1'b1;		//s0 -> 1
			s1 <= 1'b0;
			s2 <= 1'b0;
			s3 <= 1'b0;
			s4 <= 1'b0;
		end
		else if(addr_in[15:8] === 8'h01) begin	//base address = 01
			s0 <= 1'b0;
			s1 <= 1'b1;		//s1 -> 1
			s2 <= 1'b0;
			s3 <= 1'b0;
			s4 <= 1'b0;
		end
		else if(addr_in[15:8] === 8'h02) begin	//base address = 02
			s0 <= 1'b0;
			s1 <= 1'b0;
			s2 <= 1'b1;		//s2 -> 1
			s3 <= 1'b0;
			s4 <= 1'b0;
		end
		else if(addr_in[15:8] === 8'h03) begin	//base address = 03
			s0 <= 1'b0;
			s1 <= 1'b0;
			s2 <= 1'b0;
			s3 <= 1'b1;		//s3 -> 1
			s4 <= 1'b0;
		end
		else if(addr_in[15:8] === 8'h04) begin	//base address = 04
			s0 <= 1'b0;
			s1 <= 1'b0;
			s2 <= 1'b0;
			s3 <= 1'b0;
			s4 <= 1'b1;		//s4 -> 1
		end
		else begin		//error handling
			s0 <= 1'b0;
			s1 <= 1'b0;
			s2 <= 1'b0;
			s3 <= 1'b0;
			s4 <= 1'b0;
		end
	end	
endmodule
