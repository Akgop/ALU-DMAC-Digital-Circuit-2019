module mux2(d0, d1, s, y);	//1bit 2-to-1 mux
	input d0, d1, s;
	output y;
	assign y = (s == 1'b1) ? d0 : d1;
endmodule

module mux2_16bits(d0, d1, s, y);	//16bit 2-to-1 mux
	input [15:0] d0, d1;
	input	s;
	output [15:0] y;
	assign y = (s == 1'b1) ? d0 : d1;
endmodule

module mux2_32bits(d0, d1, s, y);	//32bit 2-to-1 mux
	input [31:0] d0, d1;
	input s;
	output [31:0] y;
	assign y = (s == 1'b1) ? d0 : d1;
endmodule

module mux5_32bits(d0, d1, d2, d3, d4, s, y);	//32bit 5-to-1 mux
	input [31:0] d0, d1, d2, d3, d4;
	input [4:0] s;
	output reg [31:0] y;
	
	always @ (s or d0 or d1 or d2 or d3 or d4) begin	//one-hot encoding
		case(s)
			5'b10000: y <= d0;
			5'b01000: y <= d1;
			5'b00100: y <= d2;
			5'b00010: y <= d3;
			5'b00001: y <= d4;
			default: y <= 32'b0;
		endcase
	end
endmodule
