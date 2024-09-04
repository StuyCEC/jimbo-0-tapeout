`include "ALU.v"

`define MOV 		4'b0000
`define STO 		4'b0001
`define LD  		4'b0010 
`define ADD_INC 	4'b0011
`define ADC 		4'b0100
`define SUB_DEC 	4'b0101
`define SBB 		4'b0110
`define SHLR   		4'b0111
`define NAND_NOR  	4'b1000
`define AND_OR   	4'b1001
`define XOR_NOT   	4'b1010
`define JMP  		4'b1011
`define JNZ  		4'b1100
`define JNC_JNB  	4'b1101
`define JNL_JNE  	4'b1110
`define NOP  		4'b1111

`define FETCH 0
`define STAGE_0 1
`define STAGE_1 2
`define STAGE_2 3
`define STAGE_3 4
`define STAGE_4 5

module CPU (
	input wire clk,
	input wire reset,
	inout reg [3:0] bus_data,
	output reg [11:0] bus_addr
);

	reg [3:0] state;
	reg [3:0] fetch_state;

	reg bus_data_rw; //0 for r, 1 for w
	reg [3:0] bus_data_out;

	assign bus_data = bus_data_rw ? 4'hz : bus_data_out;

	reg [3:0] reg_bank [0:6];

	reg [3:0] alu_a;
	reg [3:0] alu_b;
	reg [3:0] alu_mode;

	wire [3:0] alu_o;
	wire [3:0] alu_f;

	reg [11:0] reg_instruction;
	reg [11:0] program_counter;

	wire [3:0] opcode;
	wire [1:0] option;
	wire [2:0] arg1;
	wire [2:0] arg2;

	assign opcode = reg_instruction[11:8];
	assign option = reg_instruction[7:6];
	assign arg1 = reg_instruction[5:3];
	assign arg2 = reg_instruction[2:0];

	ALU alu(
		.a(alu_a),
		.b(alu_b),
		.mode(alu_mode),
		.carry_f(reg_f[0]),
		.borrow_f(reg_f[1]),
		.c(alu_o),
		.flags(alu_f)
	);

	always @(posedge clk) begin
		if (reset) begin
			state = FETCH;
			fetch_state = 0;

			reg_bank[0] = 4'b0000;
			reg_bank[1] = 4'b0000;
			reg_bank[2] = 4'b0000;
			reg_bank[3] = 4'b0000;
			reg_bank[4] = 4'b0000;
			reg_bank[5] = 4'b0000;
			reg_bank[6] = 4'b0000;

			alu_a = 4'b0000;
			alu_b = 4'b0000;
			alu_mode = 4'b0000;

			reg_instruction = 11'h0;
			program_counter = 11'h0;

			bus_addr = 11'h0;
			bus_data_rw = 1'b0;
			bus_data_out = 4'b0000;

		end else begin
			case (state)
				FETCH: begin
					case (fetch_state)
						0: begin
							bus_data_rw = 1'b0;
							bus_addr = program_counter;
							fetch_state = 1;
						end
						1: begin
							reg_instruction[3:0] = bus_data;
							program_counter = program_counter + 1;
							bus_addr = program_counter;
							fetch_state = 2;
						end
						2: begin
							reg_instruction[7:4] = bus_data;
							program_counter = program_counter + 1;
							bus_addr = program_counter;
							fetch_state = 3;
						end
						3: begin
							reg_instruction[11:8] = bus_data;
							program_counter = program_counter + 1;
							bus_addr = program_counter;
							fetch_state = 0; //Reset fetch state
							state = STAGE_0;
						end
					endcase
				end
				STAGE_0: begin
					case (opcode)
						MOV: begin
							case (option)
								2'b00: begin
									reg_bank[arg2] = reg_bank[arg1];
								end
								2'b01: begin
									reg_bank[arg2] = arg1;
								end
							endcase
						end
						
						STO: begin
							case (option)
								2'b00: begin
									bus_data_rw = 1'b1;
									bus_addr = {reg_bank[6], reg_bank[5], reg_bank[4]};
								end
								2'b01: begin
									bus_addr[3:0] = arg1;
								end
							endcase
						end

						LD: begin
							case (option)
								2'b00: begin
									bus_data_rw = 0'b1;
									bus_addr = {reg_bank[6], reg_bank[5], reg_bank[4]};
								end
								2'b01: begin
									bus_addr[3:0] = arg1;
								end
							endcase
						end

						ADD_INC: begin
							alu_mode = 4'b0000;
							case (option)
								2'b00: begin
									alu_a = reg_bank[arg1];
									alu_b = reg_bank[arg2];
								end
								2'b01: begin
									alu_a = arg1;
									alu_b = reg_bank[arg2];
								end
								2'b10: begin
									alu_a = 4'b0001;
									alu_b = reg_bank[arg2];
								end
							endcase
						end

						ADC: begin
							alu_mode = 4'b0001;
							case (option)
								2'b00: begin
									alu_a = reg_bank[arg1];
									alu_b = reg_bank[arg2];
								end
								2'b01: begin
									alu_a = arg1;
									alu_b = reg_bank[arg2];
								end
							endcase
						end
						
						SUB_DEC: begin
							alu_mode = 4'b0010;
							case (option)
								2'b00: begin
									alu_a = reg_bank[arg1];
									alu_b = reg_bank[arg2];
								end
								2'b01: begin
									alu_a = arg1;
									alu_b = reg_bank[arg2];
								end
								2'b10: begin
									alu_a = 4'b0001;
									alu_b = reg_bank[arg2];
								end
							endcase
						end

						SBB: begin
							alu_mode = 4'b0011;
							case (option)
								2'b00: begin
									alu_a = reg_bank[arg1];
									alu_b = reg_bank[arg2];
								end
								2'b01: begin
									alu_a = arg1;
									alu_b = reg_bank[arg2];
								end
							endcase
						end
						
						SHLR: begin
							case (option)
								2'b00: begin
									alu_mode = 4'b0100;
									alu_a = reg_bank[arg2];
								end
								2'b01: begin
									alu_mode = 4'b0101;
									alu_a = reg_bank[arg2];
								end
							endcase
						end









				end


					

					




		end
	end




endmodule
