module control_unit (clock, reset, I, flags, constant, CW, status);
	input clock, reset;
	input [31:0] I;
	input [3:0] flags, status;
	output reg [63:0] constant;
	output [35:0] CW;
	
	reg [4:0] DA, SA, SB, FS;
	reg WR, Bsel, C0, EN_B, EN_ADDR_ALU, EN_ALU, mem_read, mem_write, 
		 Status_load, PCSel, EN_ADDR_PC, EN_PC, V, C, N, Z;
	
	assign {V, C, N, Z} = flags;
			 
	reg [1:0] size, PS;
	
	assign CW = {PS, EN_PC, EN_ADDR_ALU, PCSel, 
					 Status_load, size, mem_write, mem_read, EN_ALU, 
					 EN_ADDR_ALU, EN_B, C0, FS, Bsel, WR, SB, SA, DA};
	
	
	reg [10:0] opcode;
	
	always_comb opcode = I[31:21]; 
	
	reg IF;
	reg [1:0] EX;
	
	initial begin
		PS = 0;
		WR = 0;
		mem_write = 0;
		IF = 1;
	end
	
	always_ff @(posedge clock or posedge reset) begin
		if (reset) begin
			//do reset things
		end 
		else begin
			if (IF) begin
				WR <= 0;
				mem_write <= 0;
				PS <= 0;
				C0 <= 0;
				Status_load <= 0;
				mem_read <= 0;
				EN_PC <= 0;
				EN_ALU <= 0;
				EN_B <= 0;
				IF <= 0;
				EX <=0;
			end
			else if (opcode[5]) begin//checks for all branches
				case (opcode[10:8]) 
					3'b000: begin //normal branch
						PS <= 3;
						PCSel <= 1;
						constant <= 32'(signed'(I[25:0]));
						IF <= 1;
					end
					3'b010: begin //B.cond
						bit branch;
						case (I[4:0])
							0: branch = Z;
							1: branch = ~Z;
							2: branch =	C;
							3: branch = ~C;
							4: branch = N;
							5: branch = ~N;
							6: branch = V;
							7: branch = ~V;
							8: branch = C & ~Z;
							9: branch = ~C & Z;
							10: branch = ~(N ^ V);
							11: branch = N ^ V;
							12: branch = ~Z & ~(N ^ V);
							13: branch = Z | (N ^ V);
							14: branch = 1;
							15: branch = 1;
						endcase
						if (branch) begin
							PS <= 3;
							PCSel <= 1;
							constant <= 32'(signed'(I[23:5]));
						end 
						else begin
							PS <= 1;
						end
						IF <= 1;
					end
					3'b100: begin //Branch with link
						WR <= 1;
						DA <= 30;
						EN_PC <= 1;
						PCSel <= 1;
						constant <= 32'(signed'(I[25:0]));
						PS <= 3;
						IF <= 1;
					end
					3'b101: begin //CBZ CBNZ
						if (EX == 0) begin
							SA <= I[4:0];
							SB <= 31;
							FS <= 5'b00100;
							Bsel <= 0;
							EX <= 1;
						end
						else begin	
							if ((opcode[3] & ~status[0]) |
								 (~opcode[3] & status[0])) begin	
								PS <= 3;
								PCSel <= 1;
								constant <= 32'(signed'(I[23:5]));
							end
							else begin
								PS <= 1;
							end
						IF <= 1;
						end
					end
					3'b110: begin //Branch to register
						SA <= I[9:5];
						PCSel <= 0;
						PS <= 2;
						IF <= 1;
					end
				endcase 
			end
			else begin //Other Instructions not Branches	
				case (opcode[4:2])
					3'b000: begin	
						if (EX == 0)begin	//needed for both (LDUR STUR)
							SA <= I[9:5];
							Bsel <= 1;
							constant <= 64'(signed'(I[20:12]));
							FS <= 5'b01000;
							EX <= 1;
							if (opcode[1]) begin
								WR <= 1;
								DA <= I[4:0];
								mem_read <= 1;
							end
							else begin
								SB <= I[4:0];
								EN_B <= 1;
								mem_write <= 1;
							end
						end
						else begin
							PS <= 1;
							IF <= 1;
						end
					end
					3'b010: begin //I Arithmetic
						DA <= I[4:0];
						SA <= I[9:5];
						constant <= I[21:10];
						Bsel <= 1;
						EN_ALU <= 1;
						WR <= 1;
						PS <= 1;
						IF <= 1;
						Status_load <= opcode[8];
						if (opcode[9]) begin
							FS <= 5'b01001;
							C0 <= 1;
						end
						else begin
							FS <= 5'b01000;
						end
					end
					3'b100: begin //logic
						WR <= 1;
						EN_ALU <= 1;
						PS <= 1;
						DA <= I[4:0];
						SA <= I[9:5];
						IF <= 1;
						case (opcode[9:8])
							2'b00: FS <= 5'b00000;//ANDI
							2'b01: FS <= 5'b00100;//ORRI
							2'b10: FS <= 5'b01100;//EORI
							2'b11: begin
								FS <= 5'b00000;//ANDIS
								Status_load <= 1;
							end
						endcase 
						if (opcode[7]) begin//I format
							constant <= I[21:10];
							Bsel <= 1;
						end
						else begin //R format
							SB <= I[20:16];
							Bsel <= 0;
						end
					end
					3'b101: begin //IW MOVZ MOVK
						DA <= I[4:0];
						WR <= 1;
						Bsel <= 1;
						EN_ALU <= 1;
						if (opcode[8]) begin
							if (EX == 0) begin
								PS <= 0;
								FS <=5'b00001;
								SA <= I[9:5];
								constant <= 16'hFFFF << (I[22:21] * 16);
								EX <= 1;
							end
							else begin
								PS <= 1;
								FS <= 5'b00100;
								constant <= I[20:5] << (I[22:21] * 16);
								IF <= 1; 
							end
						end
						else begin //MOVZ
							SA <= 31;
							FS <= 5'b00100;
							PS <= 1;
							constant <= I[20:5] << (I[22:21] * 16);
							IF <= 1;
						end
					end
					3'b110: begin//R-Arith/Shift
						WR <= 1;
						DA <= I[4:0];
						SA <= I[9:5];
						EN_ALU <= 1;
						IF <= 1;
						PS <= 1;
						if (opcode[1]) begin//shift
							constant <= I[15:10];
							Bsel <= 1;
							if (~opcode[0]) begin//shift right
								FS <= 5'b10100;
							end
							else begin
								FS <= 5'b10000;
							end
						end
						else begin //arithmetic
							Bsel <= 0;
							SB <= I[20:16];
							Status_load = opcode[8];
							if (opcode[9]) begin //subtract
								FS <= 5'b01001;
								C0 <= 1;
							end
							else begin
								FS <= 5'b01000;
							end
						end
					end
				endcase
			end
		end
	end
endmodule
