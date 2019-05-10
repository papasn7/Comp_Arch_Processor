module write_ECE (clock, reset, data, address, mem_write);
	
	input [63:0] data;
	input [31:0] address;
	input clock, reset, mem_write; 
	
	RegisterNbit SFR0 (.Q(R0), .D(data[15:0]), .L(address[10] & mem_write), .R(reset), .clock(clock));
	RegisterNbit SFR1 (.Q(R1), .D(data[15:0]), .L(address[11] & mem_write), .R(reset), .clock(clock));
	RegisterNbit SFR2 (.Q(R2), .D(data[15:0]), .L(address[12] & mem_write), .R(reset), .clock(clock));
	RegisterNbit SFR3 (.Q(R3), .D(data[15:0]), .L(address[13] & mem_write), .R(reset), .clock(clock));
	RegisterNbit SFR4 (.Q(R4), .D(data[15:0]), .L(address[14] & mem_write), .R(reset), .clock(clock));
	RegisterNbit SFR5 (.Q(R5), .D(data[15:0]), .L(address[15] & mem_write), .R(reset), .clock(clock));
	RegisterNbit SFR6 (.Q(R6), .D(data[15:0]), .L(address[16] & mem_write), .R(reset), .clock(clock));
	RegisterNbit SFR7 (.Q(R7), .D(data[15:0]), .L(address[17] & mem_write), .R(reset), .clock(clock));
	
	defparam SFR0.N = 16;
	defparam SFR1.N = 16;
	defparam SFR2.N = 16;
	defparam SFR3.N = 16;
	defparam SFR4.N = 16;
	defparam SFR5.N = 16;
	defparam SFR6.N = 16;
	defparam SFR7.N = 16;
endmodule
	