module ram(clk, cen, wen, addr, din, dout);	//RAM
	input clk, wen, cen;
	input [15:0] addr;
	input [31:0] din;
	output reg [31:0] dout;
	
	reg [31:0]	mem [0:63];
	
	integer i;
	
	initial begin
		for(i=0; i<64; i=i+1) begin
			mem[i] = 32'b0;
		end
	end
	
	always @ (posedge clk) begin
		if(cen == 1'b0) dout <= 32'b0;
		else if(cen == 1'b1 && wen == 1'b0) dout <= mem[addr[7:0]];
		else if(cen == 1'b1 && wen == 1'b1)	mem[addr[7:0]] <= din;
		else dout <= 32'bx;
	end
endmodule
