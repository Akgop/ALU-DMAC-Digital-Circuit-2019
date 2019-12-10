module _NOT(a,y);
	input [63:0] a;
	output [63:0] y;
	assign y = ~a;
endmodule

module _AND(a,b,y);
	input [63:0] a, b;
	output [63:0] y;
	assign y = a & b;
endmodule

module _OR(a,b,y);
	input [63:0] a, b;
	output [63:0] y;
	assign y = a | b;
endmodule

module _XOR(a,b,y);
	input [63:0] a, b;
	output [63:0] y;
	assign y = a ^ b;
endmodule

module _XNOR(a,b,y);
	input [63:0] a, b;
	output [63:0] y;
	assign y = a ^~ b;
endmodule




