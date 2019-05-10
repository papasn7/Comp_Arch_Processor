module control_unit_and_datapath (clock, reset); //(CLOCK_50, BUTTON, GPIO0_D, GPIO1_D);

	//input [2:0] BUTTON;
	//input CLOCK_50;
	input clock, reset;
	wire [35:0] CW;
	wire [63:0] constant;
	wire [4:0] flags, status;
	wire [31:0] I;
	wire [63:0] R0, R1, R2, R3, R4, R5, R6, R7;
	
	//output [31:0] GPIO0_D, GPIO1_D;
	
	//wire clkPLL, locked, clock;
	
	//PLL pll(.inclk0(CLOCK_50), .c0(clkPLL), .locked(locked));
	
	//assign clock = locked ? clkPLL : 0;
	
	control_unit ctrl (clock, reset/*~BUTTON[0]*/, I, flags, constant, CW, status);
	
	datapath path (CW, I, constant, reset/*~BUTTON[0]*/, clock, status, flags, R0, R1, R2, R3, R4, R5, R6, R7);
	
	/*GPIO_Board gpio (
		.clock_50(CLOCK_50), // connect to CLOCK_50 of the DE0
		.R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7), // row display inputs
		.GPIO_0(GPIO0_D), // (output) connect to GPIO0_D
		.GPIO_1(GPIO1_D)
	);*/

endmodule
