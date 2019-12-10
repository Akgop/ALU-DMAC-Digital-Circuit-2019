module dff_r(clk, reset_n, d, q);
	input clk, reset_n;
	input d;
	output reg q;
	
	always @ (posedge clk or negedge reset_n) begin
		if(reset_n == 1'b0) q <= 2'b0;
		else q <= d;
	end
endmodule

module dff2_r(clk, reset_n, d, q);
	input clk, reset_n;
	input [1:0] d;
	output reg [1:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if(reset_n == 1'b0) q <= 2'b0;
		else q <= d;
	end
endmodule

module dff3_r(clk, reset_n, d, q);
	input clk, reset_n;
	input [2:0] d;
	output reg [2:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if(reset_n == 1'b0) q <= 3'b0;
		else q <= d;
	end
endmodule

module dff4_r(clk, reset_n, d, q);
	input clk, reset_n;
	input [3:0] d;
	output reg [3:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if(reset_n == 1'b0) q <= 4'b0;
		else q <= d;
	end
endmodule

module dff5_r(clk, reset_n, d, q);
	input clk, reset_n;
	input [4:0] d;
	output reg [4:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if(reset_n == 1'b0) q <= 5'b0;
		else q <= d;
	end
endmodule

module dff6_r(clk, reset_n, d, q);
	input clk, reset_n;
	input [5:0] d;
	output reg [5:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if(reset_n == 1'b0) q <= 6'b0;
		else q <= d;
	end
endmodule

module dff10_r(clk, reset_n, d, q);	//10bit resettable & enable dff
	input clk, reset_n;
	input [9:0] d;
	output reg [9:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if(reset_n == 1'b0) q <= 10'b0;
		else q <= d;
	end
endmodule

module dff32_r(clk, reset_n, d, q);
	input clk, reset_n;
	input [31:0] d;
	output reg [31:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if(reset_n == 1'b0) q <= 32'b0;
		else q <= d;
	end
endmodule

module dff32_r_en(clk, reset_n, en, d, q);	//32bit resettable & enable dff
	input clk, reset_n, en;
	input [31:0] d;
	output reg [31:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if (reset_n == 1'b0) q <= 32'b0;
		else if(en == 1'b0) q <= q;
		else q <= d;
	end
endmodule

module dff32_r_en_c(clk, reset_n, en, c, d, q);	//32bit resettable & enable & clear dff
	input clk, reset_n, en, c;
	input [31:0] d;
	output reg [31:0] q;
	
	always @ (posedge clk or negedge reset_n or negedge c) begin
		if (reset_n == 1'b0 || c == 1'b0) q <= 32'b0;
		else if(en == 1'b0) q <= q;
		else q <= d;
	end
endmodule

module dff32_r_en2(clk, reset_n, en, d, q);
	input clk, reset_n, en;
	input [31:0] d;
	output reg [31:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if (reset_n == 1'b0) q <= 32'b0;
		else if(en != 1'b1) q <= 32'b0;
		else q <= d;
	end
endmodule

module dff32_r_en_en(clk, reset_n, en, en2, d, q);
	input clk, reset_n, en;
	input [1:0] en2;
	input [31:0] d;
	output reg [31:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if (reset_n == 1'b0) q <= 32'b0;
		else if(en == 1'b1) q <= d;
		else if(en2 == 2'b10) q <= 32'h1;
		else q <= q;
	end
endmodule


module dff64_r(clk, reset_n, d, q);
	input clk, reset_n;
	input [63:0] d;
	output reg [63:0] q;
	
	always @ (posedge clk or negedge reset_n) begin
		if(reset_n == 1'b0) q <= 64'b0;
		else q <= d;
	end
endmodule
