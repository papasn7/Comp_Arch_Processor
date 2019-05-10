module control_unit_and_datapath_testbench();

	//reg CLOCK_50;
	//reg [2:0] BUTTON;
	//wire [31:0] GPIO0_D, GPIO1_D;
	
	reg clock, reset;
	
	
	control_unit_and_datapath dut (clock, reset);
	
	initial begin
		/*BUTTON[0] <= 1;
		CLOCK_50 <= 1'b0;
		#10
		BUTTON[0] <= 0;
		#2000 $stop;*/
		reset <= 1;
		clock <= 0;
		#10
		reset <= 0;
		#500 $stop;
	end
	
	always
	//#5 CLOCK_50 <= ~CLOCK_50;
	#5 clock <= ~clock;
	
	wire [31:0] I;
	assign I = dut.I;
	wire [36:0] CW;
	assign CW = dut.CW;
	wire [63:0] R0; 
	assign R0 = dut.path.inst_reg.R00;
	wire [63:0] R1; 
	assign R1 = dut.path.inst_reg.R01;
	wire [63:0] R2; 
	assign R2 = dut.path.inst_reg.R02;
	wire [63:0] R3; 
	assign R3 = dut.path.inst_reg.R03;
	wire [63:0] R4; 
	assign R4 = dut.path.inst_reg.R04;
	wire [63:0] R5; 
	assign R5 = dut.path.inst_reg.R05;
	wire [63:0] R6; 
	assign R6 = dut.path.inst_reg.R06;
	wire [63:0] R7; 
	assign R7 = dut.path.inst_reg.R07;
	wire [31:0] PC_out; 
	assign PC_out = dut.path.PC_out;
	wire [63:0] mem[0:1023];
	assign mem = dut.path.ram.mem;
	wire [3:0] status;
	assign status = dut.path.inst_alu.status;
	wire C0;
	assign C0 = dut.path.inst_alu.C0;


endmodule
