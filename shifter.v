module LSL(din, dout, shamt);
	input [63:0] din;
	input [1:0] shamt;
	output reg [63:0] dout;
		
	always @ (shamt or din) begin
		if(shamt == 2'b00) dout <= din;
		else if(shamt == 2'b01) begin
			dout[63:1] <= din[62:0];
			dout[0] <= 1'b0;
		end
		else if(shamt == 2'b10) begin
			dout[63:2] <= din[61:0];
			dout[1:0] <= 2'b0;
		end
		else begin
			dout[63:3] <= din[60:0];
			dout[2:0] <= 3'b0;
		end
	end	
endmodule

module LSR(din, dout, shamt);
	input [63:0] din;
	input [1:0] shamt;
	output reg [63:0] dout;
	
	always @ (shamt or din) begin
		if(shamt == 2'b00) dout <= din;
		else if(shamt == 2'b01) begin
			dout[62:0] <= din[63:1];
			dout[63] <= 1'b0;
		end	
		else if(shamt == 2'b10) begin
			dout[61:0] <= din[63:2];
			dout[63:62] <= 2'b0;
		end
		else begin
			dout[60:0] <= din[63:3];
			dout[63:61] <= 3'b0;
		end
	end
endmodule

module ASR(din, dout, shamt);
	input [63:0] din;
	input [1:0] shamt;
	output reg [63:0] dout;
	
	always @ (shamt or din) begin
		if(shamt == 2'b00) dout <= din;
		else if(shamt == 2'b01) begin
			dout[62:0] <= din[63:1];
			dout[63] <= din[63];
		end	
		else if(shamt == 2'b10) begin
			dout[61:0] <= din[63:2];
			dout[63:62] <= {din[63], din[63]};
		end
		else begin
			dout[60:0] <= din[63:3];
			dout[63:61] <= {din[63], din[63], din[63]};
		end
	end
endmodule
