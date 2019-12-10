module CLA(a,b,ci,s,co);
	input [63:0] a, b;
	input ci;
	output [63:0] s;
	output co;
	
	wire c1;
	
	cla32 U0_f(a[31:0], b[31:0], ci, s[31:0], c1);
	cla32 U1_b(a[63:32], b[63:32], c1, s[63:32], co);
	
endmodule

module cla32(a,b,ci,s,co);
	input [31:0] a,b;
	input ci;
	output [31:0] s;
	output co;
	
	wire c1, c2, c3, c4, c5, c6, c7;
	
	cla4 U0_cla4(.a(a[3:0]), .b(b[3:0]), .ci(ci), .s(s[3:0]), .co(c1));
	cla4 U1_cla4(.a(a[7:4]), .b(b[7:4]), .ci(c1), .s(s[7:4]), .co(c2));
	cla4 U2_cla4(.a(a[11:8]), .b(b[11:8]), .ci(c2), .s(s[11:8]), .co(c3));
	cla4 U3_cla4(.a(a[15:12]), .b(b[15:12]), .ci(c3), .s(s[15:12]), .co(c4));
	cla4 U4_cla4(.a(a[19:16]), .b(b[19:16]), .ci(c4), .s(s[19:16]), .co(c5));
	cla4 U5_cla4(.a(a[23:20]), .b(b[23:20]), .ci(c5), .s(s[23:20]), .co(c6));
	cla4 U6_cla4(.a(a[27:24]), .b(b[27:24]), .ci(c6), .s(s[27:24]), .co(c7));
	cla4 U7_cla4(.a(a[31:28]), .b(b[31:28]), .ci(c7), .s(s[31:28]), .co(co));
	
endmodule

module cla4(a,b,ci,s,co);
	input [3:0] a,b;
	input ci;
	output [3:0] s;
	output co;
	
	//assign wire for connect clb - fa_v2
	wire c1, c2, c3;
	
	//instance carry look block
	clb4 U0_clb4(.a(a), .b(b), .ci(ci), .c1(c1), .c2(c2), .c3(c3), .co(co));
		
	//instance four full adder without carry out
	fa_v2 U1_fa_v2(.a(a[0]), .b(b[0]), .ci(ci), .s(s[0]));
	fa_v2 U2_fa_v2(.a(a[1]), .b(b[1]), .ci(c1), .s(s[1]));
	fa_v2 U3_fa_v2(.a(a[2]), .b(b[2]), .ci(c2), .s(s[2]));
	fa_v2 U4_fa_v2(.a(a[3]), .b(b[3]), .ci(c3), .s(s[3]));
endmodule


module fa_v2(a,b,ci,s);
	input a,b,ci;
	output s;
	wire w0;
	assign w0 = a ^ b;
	assign s = ci ^ w0;
endmodule


module clb4(a,b,ci,c1,c2,c3,co);
	input [3:0] a,b;
	input ci;
	output c1,c2,c3,co;
	
	wire [3:0] g,p;
	
	assign g = a & b;
	assign p = a | b;
	
	assign c1 = g[0] | (p[0] & ci);
	assign c2 = g[1] | (p[1] & c1);
	assign c3 = g[2] | (p[2] & c2);
	assign co = g[3] | (p[3] & c3);
endmodule


























