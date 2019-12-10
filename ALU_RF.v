module ALU_RF(clk, reset_n, wAddr, wData, we, rd_en, rAddr, rAddr1, rAddr2, rData, rData1, rData2);
	input clk, reset_n, we, rd_en;
	input [3:0] wAddr, rAddr, rAddr1, rAddr2;
	input [31:0] wData;
	output reg [31:0] rData, rData1, rData2;
	
	wire [15:0] to_reg;
	wire [31:0] from_reg[15:0];
	wire sel;
	reg [15:0] w_a;
		
	////////////// 4-to-16 Decoder //////////////////////
	always @ (wAddr)	//when d changes
	begin
		case(wAddr)	//encoding
			4'b0000: w_a <= 16'b0000_0000_0000_0001;	
			4'b0001: w_a <= 16'b0000_0000_0000_0010;
			4'b0010: w_a <= 16'b0000_0000_0000_0100;
			4'b0011: w_a <= 16'b0000_0000_0000_1000;
			4'b0100: w_a <= 16'b0000_0000_0001_0000;
			4'b0101: w_a <= 16'b0000_0000_0010_0000;
			4'b0110: w_a <= 16'b0000_0000_0100_0000;
			4'b0111: w_a <= 16'b0000_0000_1000_0000;
			4'b1000: w_a <= 16'b0000_0001_0000_0000;	
			4'b1001: w_a <= 16'b0000_0010_0000_0000;
			4'b1010: w_a <= 16'b0000_0100_0000_0000;
			4'b1011: w_a <= 16'b0000_1000_0000_0000;
			4'b1100: w_a <= 16'b0001_0000_0000_0000;
			4'b1101: w_a <= 16'b0010_0000_0000_0000;
			4'b1110: w_a <= 16'b0100_0000_0000_0000;
			4'b1111: w_a <= 16'b1000_0000_0000_0000;
			default: w_a <= 16'hx;	//error handling.
		endcase
	end
	
	//enable signal
	assign to_reg[0] = we & w_a[0];
	assign to_reg[1] = we & w_a[1];
	assign to_reg[2] = we & w_a[2];
	assign to_reg[3] = we & w_a[3];
	assign to_reg[4] = we & w_a[4];
	assign to_reg[5] = we & w_a[5];
	assign to_reg[6] = we & w_a[6];
	assign to_reg[7] = we & w_a[7];
	assign to_reg[8] = we & w_a[8];
	assign to_reg[9] = we & w_a[9];
	assign to_reg[10] = we & w_a[10];
	assign to_reg[11] = we & w_a[11];
	assign to_reg[12] = we & w_a[12];
	assign to_reg[13] = we & w_a[13];
	assign to_reg[14] = we & w_a[14];
	assign to_reg[15] = we & w_a[15];
	
	/////////// 32bit 16 Register //////////////
	dff32_r_en U0_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[0]), .d(wData), .q(from_reg[0]));
	dff32_r_en U1_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[1]), .d(wData), .q(from_reg[1]));
	dff32_r_en U2_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[2]), .d(wData), .q(from_reg[2]));
	dff32_r_en U3_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[3]), .d(wData), .q(from_reg[3]));
	dff32_r_en U4_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[4]), .d(wData), .q(from_reg[4]));
	dff32_r_en U5_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[5]), .d(wData), .q(from_reg[5]));
	dff32_r_en U6_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[6]), .d(wData), .q(from_reg[6]));
	dff32_r_en U7_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[7]), .d(wData), .q(from_reg[7]));
	dff32_r_en U8_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[8]), .d(wData), .q(from_reg[8]));
	dff32_r_en U9_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[9]), .d(wData), .q(from_reg[9]));
	dff32_r_en U10_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[10]), .d(wData), .q(from_reg[10]));
	dff32_r_en U11_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[11]), .d(wData), .q(from_reg[11]));
	dff32_r_en U12_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[12]), .d(wData), .q(from_reg[12]));
	dff32_r_en U13_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[13]), .d(wData), .q(from_reg[13]));
	dff32_r_en U14_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[14]), .d(wData), .q(from_reg[14]));
	dff32_r_en U15_dff32_r_en(.clk(clk), .reset_n(reset_n), .en(to_reg[15]), .d(wData), .q(from_reg[15]));
	
	/////////// 16-to-1 MUX -> DATA 1 ///////////////
	always @(rAddr or from_reg or we) begin
		if(we == 1'b0) begin
			case(rAddr)	//decoding
				4'b0000: rData <= from_reg[0];	
				4'b0001: rData <= from_reg[1];	
				4'b0010: rData <= from_reg[2];	
				4'b0011: rData <= from_reg[3];	
				4'b0100: rData <= from_reg[4];	
				4'b0101: rData <= from_reg[5];	
				4'b0110: rData <= from_reg[6];	
				4'b0111: rData <= from_reg[7];	
				4'b1000: rData <= from_reg[8];	
				4'b1001: rData <= from_reg[9];	
				4'b1010: rData <= from_reg[10];	
				4'b1011: rData <= from_reg[11];	
				4'b1100: rData <= from_reg[12];	
				4'b1101: rData <= from_reg[13];	
				4'b1110: rData <= from_reg[14];
				4'b1111: rData <= from_reg[15];	
				default: rData <= 32'hx;	//error handling
			endcase
		end
		else rData <= 32'h0;
	end
	
	
	
	/////////// 16-to-1 MUX -> DATA 1 ///////////////
	always @(rAddr1 or from_reg or rd_en) begin
		if(rd_en == 1'b1) begin
			case(rAddr1)	//decoding
				4'b0000: rData1 <= from_reg[0];	
				4'b0001: rData1 <= from_reg[1];	
				4'b0010: rData1 <= from_reg[2];	
				4'b0011: rData1 <= from_reg[3];	
				4'b0100: rData1 <= from_reg[4];	
				4'b0101: rData1 <= from_reg[5];	
				4'b0110: rData1 <= from_reg[6];	
				4'b0111: rData1 <= from_reg[7];	
				4'b1000: rData1 <= from_reg[8];	
				4'b1001: rData1 <= from_reg[9];	
				4'b1010: rData1 <= from_reg[10];	
				4'b1011: rData1 <= from_reg[11];	
				4'b1100: rData1 <= from_reg[12];	
				4'b1101: rData1 <= from_reg[13];	
				4'b1110: rData1 <= from_reg[14];
				4'b1111: rData1 <= from_reg[15];	
				default: rData1 <= 32'hx;	//error handling
			endcase
		end
		else rData1 <= 32'h0;
	end
	
	/////////// 16-to-1 MUX -> DATA 2 ///////////////
	always @(rAddr2 or from_reg or rd_en)	begin
		if(rd_en == 1'b1) begin
			case(rAddr2)	//decoding
				4'b0000: rData2 <= from_reg[0];	
				4'b0001: rData2 <= from_reg[1];	
				4'b0010: rData2 <= from_reg[2];	
				4'b0011: rData2 <= from_reg[3];	
				4'b0100: rData2 <= from_reg[4];	
				4'b0101: rData2 <= from_reg[5];	
				4'b0110: rData2 <= from_reg[6];	
				4'b0111: rData2 <= from_reg[7];	
				4'b1000: rData2 <= from_reg[8];	
				4'b1001: rData2 <= from_reg[9];	
				4'b1010: rData2 <= from_reg[10];	
				4'b1011: rData2 <= from_reg[11];	
				4'b1100: rData2 <= from_reg[12];	
				4'b1101: rData2 <= from_reg[13];	
				4'b1110: rData2 <= from_reg[14];
				4'b1111: rData2 <= from_reg[15];	
				default: rData2 <= 32'hx;	//error handling
			endcase
		end
		else rData2 <= 32'h0;
	end
endmodule
