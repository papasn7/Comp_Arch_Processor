module control_unit_testbench();
	
	wire [36:0]control_word;
	wire [63:0]constant;
	wire [3:0] flags;
	reg[4:0]status;
	reg[31:0]I;
	reg clock, reset; 
	
	
	control_unit instcontrol_unit (.clock(clock), .reset(reset), .I(I), .flags(flags), 
											 .constant(constant), .CW(control_word), .status(status));
	
	
	initial begin
		clock <= 1'b1;
		reset <= 1'b1;
		#5
		reset <= 1'b0;
		#100 $stop;
	end
	
	
	always
	#5 clock <= ~clock;
		
	always begin
		#20
		I <= 32'b10010001000000011001001111100100; // ADDI X4, XZR, 100
		#20
		I <= 32'b11010010100000000011001000001000; // MOVZ X8, 400 
		#20
		I <= 32'b11010010100000001001011000001001; // MOVZ X9, 1200 
		#20;
		I <= 32'b10110001000000001010000001000001; // ADDIS X1, X2, 40
		#400 $stop;
		
	
	end
	
endmodule
