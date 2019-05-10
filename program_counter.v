module program_counter (clk, rst, ps, pc_in, pc_out, pc_4);
	input clk, rst;
	input [1:0] ps;
	input [31:0] pc_in;
	output reg [31:0] pc_out = 0;
	output [31:0] pc_4;
	
	assign pc_4 = pc_out + 4;
	//ps 00 - hold
	//ps 01 - increment (pc <= pc + 4)
	//ps 10 - load (pc <= pc_in)
	//ps 11 - offset (pc <= pc + pc_in)
	always @(posedge clk or posedge rst) 
	begin
		if(rst) pc_out <= 0;
		else case (ps) 
			0: pc_out <= pc_out;
			1: pc_out <= pc_out + 4;
			2: pc_out <= pc_in;
			3: pc_out <= pc_out + (pc_in * 4) + 4;
		endcase
	end
endmodule
	