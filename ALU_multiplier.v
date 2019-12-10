module ALU_multiplier(clk, reset_n, op_start, op_clear, multiplicand, multiplier, result, op_done); //Top Module
	input clk, reset_n, op_start, op_clear;
	input [31:0] multiplicand, multiplier;
	output [63:0] result;
	output op_done;
	
	//wires for connect each sub modules
	wire [5:0] next_cnt, cnt;
	wire [1:0] next_state, state;
	wire [31:0] next_A, next_X, A, X;
	wire [63:0] next_result;
	wire [63:0] temp_result;
	
	multiplier_ns_logic U0_multiplier_ns_logic(	//ns_logic
				.op_start(op_start), 
				.op_clear(op_clear), 
				.cnt(cnt),
				.state(state), 
				.next_state(next_state),
				.next_cnt(next_cnt));
				
	multiplier_cal_logic U1_multiplier_cal_logic(	//cal_logic
				.state(next_state), 
				.multiplicand(multiplicand), 
				.multiplier(multiplier), 
				.prev_A(A), 
				.prev_X(X), 
				.prev_result(temp_result), 
				.prev_cnt(cnt), 
				.A(next_A), 
				.X(next_X), 
				.result(next_result));
		
	dff2_r U2_state_mul(	//state dff
				.clk(clk), .reset_n(reset_n), 
				.d(next_state), .q(state));
	
	dff32_r U3_multiplicand(	//multiplicand
				.clk(clk), .reset_n(reset_n), 
				.d(next_A), .q(A));
	
	dff32_r U4_multiplier(		//multiplier
				.clk(clk), .reset_n(reset_n), 
				.d(next_X), .q(X));
	
	dff6_r U5_counter(		//counter dff
				.clk(clk), .reset_n(reset_n),
				.d(next_cnt), .q(cnt));
	
	
	dff64_r U6_result(//result dff
				.clk(clk), .reset_n(reset_n),
				.d(next_result), .q(temp_result));
				
	multiplier_o_logic U7_o_logic(	//o_logic
				.state(state), 
				.result_in(temp_result), 
				.result_out(result), 
				.op_done(op_done));
				
endmodule


module multiplier_ns_logic(op_start, op_clear, cnt, state, next_state, next_cnt);//next state logic
	input [1:0] state;
	input op_start, op_clear;
	input [5:0] cnt;
	output reg [1:0] next_state;
	output reg [5:0] next_cnt;
	
	//state encoding
	parameter IDLE = 2'b00;
	parameter EXEC = 2'b01;
	parameter DONE = 2'b10;
	
	//when inputs changes
	always @ (state or op_clear or op_start or cnt) begin
		case(state)
			IDLE: begin	//state == IDLE
				if(op_clear == 1'b1) begin
					next_state <= IDLE;	//if op_clear == 1 -> IDLE
					next_cnt <= 6'b0;		//count = 0
				end
				else if(op_start == 1'b0) begin	//if op_start == 0 -> IDLE
					next_state <= IDLE;	
					next_cnt <= 6'b0;		//count = 0
				end
				else if(op_start == 1'b1) begin	//if op_start == 1 -> EXEC
					next_state <= EXEC;
					next_cnt <= cnt + 1'b1;	//count++
				end
				else begin		//error handling
					next_state <= 2'bx;
					next_cnt <= 6'bx;
				end
			end
			EXEC: begin	//state == EXEC
				if(op_clear == 1'b1) begin	//op_clear == 1 -> IDLE
					next_state <= IDLE;
					next_cnt <= 6'b0;	//count = 0
				end
				else if(cnt === 6'b01_1111) begin	//if count == 63 -> DONE
					next_state <= DONE;
					next_cnt <= cnt + 1'b1;	//count ++ 
				end
				else if(cnt !== 6'b01_1111) begin	//if count < 63 -> EXEC
					next_state <= EXEC;
					next_cnt <= cnt + 1'b1;	//count ++ 
				end
				else begin
					next_state <= 2'bx;	//error handling
					next_cnt <= 6'bx;
				end
			end
			DONE: begin	//state == DONE
				if(op_clear == 1'b1) begin	//if op_clear == 1 -> IDLE
					next_state <= IDLE;
					next_cnt <= 6'b0;	//count = 0
				end
				else if(op_clear == 1'b0) begin	//else -> DONE
					next_state <= DONE;
					next_cnt <= cnt;	//prev value
				end
				else begin
					next_state <= 2'bx;	//error handling
					next_cnt <= 6'bx;
				end
			end
			default: begin
				next_state <= 2'bx;	//error handling
				next_cnt <= 6'bx;
			end
		endcase
	end
endmodule




module multiplier_cal_logic(state, multiplicand, multiplier, 
			prev_A, prev_X, prev_result, prev_cnt, A, X, result);	//Booth Multiplication module
	
	//I/O
	input [1:0] state;
	input [31:0] multiplicand, multiplier;
	input [31:0] prev_A, prev_X;
	input [63:0] prev_result;
	input [5:0] prev_cnt;
	output reg [31:0] A, X;
	output reg [63:0] result;
	
	//wires
	wire [31:0] lsr_x;	//logical shift left X
	wire lsb_x;				//prev_X 's LSB
	wire [1:0] sel_x;		//select bit
	wire [63:0] double_A, temp_result, lsr_result;	//A
	
	reg [31:0] temp_A;	//A
	
	//State Encoding
	parameter IDLE = 2'b00;
	parameter EXEC = 2'b01;
	parameter DONE = 2'b10;
	
	//make select signal
	assign lsr_x = prev_X >> 1;	//logical right shift 1bit
	assign lsb_x = (prev_cnt == 6'b0) ? 1'b0 : prev_X[0];	//if count == 0 -> new input, else old input
	assign sel_x = {X[0], lsb_x};	//2bit sel_x
	
	//make A, -A for Booth Algorithm
	always @ (sel_x or temp_A or A) begin
		if(sel_x == 2'b00 || sel_x == 2'b11) temp_A <= 32'b0;	//Shift Only
		else if(sel_x == 2'b01)	temp_A <= A;		//A
		else if(sel_x == 2'b10) temp_A <= ~A + 1'b1;	//-A
		else temp_A <= 32'bx;
	end
	
	assign double_A = {temp_A, 32'b0};		//64'b A -> 128'b A
	assign temp_result = prev_result + double_A;	//Adder
	assign lsr_result = temp_result >> 1;	//shifter
	
	//calculate next values for dff
	always @ (prev_A or prev_X or prev_cnt or prev_result 
			or multiplicand or multiplier or lsr_x or temp_result or lsr_result or state) begin
		case(state)
			IDLE: begin	//when IDLE state
				A <= 32'b0;
				X <= 32'b0;
				result <= 64'b0;	//everything 0
			end
			EXEC: begin	//when EXEC state
				X <= (prev_cnt === 6'b0) ? multiplier : lsr_x;	//output X (multiplier)
				A <= (prev_cnt === 6'b0) ? multiplicand : prev_A;	//output A (multiplicand)
				result <= {temp_result[63], lsr_result[62:0]};	//sign extension
			end
			DONE: begin	//when DONE state
				if(prev_cnt === 6'b01_1111) begin	//when count == 63
					X <= (prev_cnt === 6'b0) ? multiplier : lsr_x;	//output X (multiplier)
					A <= (prev_cnt === 6'b0) ? multiplicand : prev_A;	//output A (multiplicand)
					result <= {temp_result[63], lsr_result[62:0]};	//sign extension
				end
				else begin //when count == 64
					A <= prev_A;
					X <= prev_X;
					result <= prev_result;	//everything prev value
				end
			end
			default: begin	//error handling
				A <= 32'bx;
				X <= 32'bx;
				result <= 64'bx;
			end
		endcase
	end
	
endmodule



module multiplier_o_logic(state, result_in, result_out, op_done);	//output logic
	input [1:0] state;
	input [63:0] result_in;
	output [63:0] result_out;
	output reg op_done;
	
	//encode state
	parameter IDLE = 2'b00;
	parameter EXEC = 2'b01;
	parameter DONE = 2'b10;
	
	always @ (state) begin	//when state, op_done changes
		case(state)
			IDLE:		op_done <= 1'b0;	//IDLE : 0
			EXEC: 	op_done <= 1'b0;	//EXEC : 0
			DONE: 	op_done <= 1'b1;	//DONE : 1
			default	op_done <= 1'bx;	//error handling
		endcase
	end
	
	assign result_out = result_in;	//print result
	
endmodule






