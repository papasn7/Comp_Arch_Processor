module datapath (control_word, rom_out, constant, reset, clock, status, flags, R0, R1, R2, R3, R4, R5, R6, R7);

	logic [63:0] data;
	logic [63:0] reg_out;
	logic [63:0] mem_out;
	logic [63:0] alu_out;
	logic [31:0] pc_4;
	
	wire [31:0] PC_out;
	output [31:0] rom_out;
	input [35:0] control_word;
	input clock, reset;
	input [63:0] constant;
	output [3:0] status;
	output logic [3:0] flags;
	output [63:0] R0, R1, R2, R3, R4, R5, R6, R7;
	
	wire Status_load, PCsel, EN_ADDR_PC, EN_PC;
	wire [1:0] PS;
	
	wire [63:0] A, B, raminout;
	wire [4:0] DA, SA, SB, FS;
	wire WR, Bsel, C0, EN_B, EN_ADDR_ALU, EN_ALU;
	wire [1:0] Mem;
	wire mem_read, mem_write;
	
	always_comb begin 
		if (mem_read)
			data = mem_out;
		else if (EN_PC)
			data = pc_4;
		else if (EN_ALU)
			data = alu_out;
		else if (EN_B)
			data = B;
		else 
			data = 64'hBAD;
	end
	
	assign DA = control_word[4:0];
	assign SA = control_word[9:5];
	assign SB = control_word[14:10];
	assign WR = control_word[15];
	assign Bsel = control_word[16];
	assign FS = control_word[21:17];
	assign C0 = control_word[22];
	assign EN_B = control_word[23];
	assign EN_ADDR_ALU = control_word[24];
	assign EN_ALU = control_word[25];
	assign mem_read = control_word[26];
	assign mem_write = control_word[27];
	assign size = control_word[29:28];
	assign Status_load = control_word[30];
	assign PCsel = control_word[31];
	assign EN_ADDR_PC = control_word[32];
	assign EN_PC = control_word[33];
	assign PS = control_word[35:34];
	
	RegisterFile32x64 inst_reg (.A(A), .B(B), .SA(SA), .SB(SB), .D(data), 
			.DA(DA), .W(WR), .reset(reset), .clock(clock), .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7));
	
	ALU_LEGv8 inst_alu (.A(A), .B(Bsel ? constant : B), .FS(FS), .C0(C0), .F(alu_out), .status(status));
	always_ff @(posedge clock) if (Status_load) flags <= status;
	
	write_ECE inst_perif (.clock(clock), .reset(reset), .data(data), .address(alu_out), .mem_write(mem_write));
	
	ram_sp_sr_sw ram (
		.clk(clock),
		.address(alu_out[9:0]),
		.data_in(data),
		.data_out(mem_out),
		.we(mem_write),
		.oe(mem_read)
	);
	
	rom_case rom (
		.address(PC_out),
		.out(rom_out)
	);
	
	program_counter inst_count(.pc_in(PCsel ? constant[31:0] : A[31:0]), .ps(PS), .rst(reset), 
			.clk(clock), .pc_out(PC_out), .pc_4(pc_4));

endmodule
