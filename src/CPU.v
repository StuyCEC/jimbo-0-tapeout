/*
 * Main 4-bit CPU Module
 */


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
`define JNL	  	    4'b1110
`define NOP  		4'b1111

`define FETCH 0
`define STAGE_0 1
`define STAGE_1 2
`define STAGE_2 3
`define STAGE_3 4
`define STAGE_4 5

module CPU (
	input wire clk,
	input wire rst_n,
	input wire [3:0] bus_data_in,
	output reg bus_data_rw,
	output reg [3:0] bus_data_out,
	output reg [11:0] bus_addr
);

	reg [3:0] state;
	reg [3:0] fetch_state;

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
		.carry_f(reg_bank[3][0]),
		.borrow_f(reg_bank[3][1]),
		.c(alu_o),
		.flags(alu_f)
	);

	always @(posedge clk) begin
		if (!rst_n) begin
			state <= `FETCH;
			fetch_state <= 0;

			reg_bank[0] <= 4'b0000;
			reg_bank[1] <= 4'b0000;
			reg_bank[2] <= 4'b0000;
			reg_bank[3] <= 4'b0000;
			reg_bank[4] <= 4'b0000;
			reg_bank[5] <= 4'b0000;
			reg_bank[6] <= 4'b0000;

			alu_a <= 4'b0000;
			alu_b <= 4'b0000;
			alu_mode <= 4'b0000;

			reg_instruction <= 12'h0;
			program_counter <= 12'h0;

			bus_addr <= 12'h0;
			bus_data_rw <= 1'b0;
			bus_data_out <= 4'b0000;

		end else begin
			case (state)
				`FETCH: begin
					case (fetch_state)
						0: begin
							bus_data_rw <= 1'b0;
							bus_addr <= program_counter;
							fetch_state <= 1;
						end
						1: begin
							reg_instruction[3:0] <= bus_data_in;
							program_counter <= program_counter + 1;
							bus_addr <= program_counter;
							fetch_state <= 2;
						end
						2: begin
							reg_instruction[7:4] <= bus_data_in;
							program_counter <= program_counter + 1;
							bus_addr <= program_counter;
							fetch_state <= 3;
						end
						3: begin
							reg_instruction[11:8] <= bus_data_in;
							program_counter <= program_counter + 1;
							bus_addr <= program_counter;
							fetch_state <= 0; //Reset fetch state
							state <= `STAGE_0;
						end
					endcase
				end
				`STAGE_0: begin
					state <= `STAGE_1;

					case (opcode)
						`MOV: begin
							case (option)
								2'b00: reg_bank[arg2] <= reg_bank[arg1];
								2'b01: reg_bank[arg2] <= bus_data_in;
								default: program_counter <= 12'b111111111111;
							endcase
							state <= `FETCH;
						end
						
						`STO: begin
							case (option)
								2'b00: begin
									bus_data_rw <= 1'b1;
									bus_addr <= {reg_bank[6], reg_bank[5], reg_bank[4]};
								end
								2'b01: begin
									reg_bank[4] <= bus_data_in;
									program_counter <= program_counter + 1;
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end

						`LD: begin
							case (option)
								2'b00: bus_addr <= {reg_bank[6], reg_bank[5], reg_bank[4]};
								2'b01: begin
									reg_bank[4] <= bus_data_in;
									program_counter <= program_counter + 1;
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end

						`ADD_INC: begin
							alu_mode <= 4'b0000;
							case (option)
								2'b00: begin
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_a <= bus_data_in;
									alu_b <= reg_bank[arg2];
								end
								2'b10: begin
									alu_a <= 4'b0001;
									alu_b <= reg_bank[arg2];
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end

						`ADC: begin
							alu_mode <= 4'b0001;
							case (option)
								2'b00: begin
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_a <= bus_data_in;
									alu_b <= reg_bank[arg2];
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end
						
						`SUB_DEC: begin
							alu_mode <= 4'b0010;
							case (option)
								2'b00: begin
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_a <= bus_data_in;
									alu_b <= reg_bank[arg2];
								end
								2'b10: begin
									alu_a <= 4'b0001;
									alu_b <= reg_bank[arg2];
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end

						`SBB: begin
							alu_mode <= 4'b0011;
							case (option)
								2'b00: begin
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_a <= bus_data_in;
									alu_b <= reg_bank[arg2];
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end
						
						`SHLR: begin
							case (option)
								2'b00: begin
									alu_mode <= 4'b0100;
									alu_a <= reg_bank[arg2];
								end
								2'b01: begin
									alu_mode <= 4'b0101;
									alu_a <= reg_bank[arg2];
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end

						`NAND_NOR: begin
							case (option)
								2'b00: begin
									alu_mode <= 4'b1010;
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_mode <= 4'b1010;
									alu_a <= bus_data_in;
									alu_b <= reg_bank[arg2];
								end
								2'b10: begin
									alu_mode <= 4'b1011;
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b11: begin
									alu_mode <= 4'b1011;
									alu_a <= bus_data_in;
									alu_b <= reg_bank[arg2];
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end
						
						`AND_OR: begin
							case (option)
								2'b00: begin
									alu_mode <= 4'b0110;
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_mode <= 4'b0110;
									alu_a <= bus_data_in;
									alu_b <= reg_bank[arg2];
								end
								2'b10: begin
									alu_mode <= 4'b0111;
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b11: begin
									alu_mode <= 4'b0111;
									alu_a <= bus_data_in;
									alu_b <= reg_bank[arg2];
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end
						
						`XOR_NOT: begin
							case (option)
								2'b00: begin
									alu_mode <= 4'b1001;
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_mode <= 4'b1001;
									alu_a <= bus_data_in;
									alu_b <= reg_bank[arg2];
								end
								2'b10: begin
									alu_mode <= 4'b1000;
									alu_a <= reg_bank[arg2];
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end

						`JMP: begin
							case (option)
								2'b00: begin
									program_counter <= {reg_bank[6], reg_bank[5], reg_bank[4]};
									state <= `FETCH;
								end
								2'b01: begin
									reg_bank[4] <= bus_data_in;
									program_counter <= program_counter + 1;
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end

						`JNZ: begin
							if (!reg_bank[3][2]) begin
								case (option)
									2'b00: begin 
										program_counter <= {reg_bank[6], reg_bank[5], reg_bank[4]};
										state <= `FETCH;
									end
									2'b01: begin
										reg_bank[4] <= bus_data_in;
										program_counter <= program_counter + 1;
									end
									default: program_counter <= 12'b111111111111;
								endcase
							end
							else begin
								state <= `FETCH;
							end
						end
						
						`JNC_JNB: begin
							case (option)
								2'b00: begin
									if (!reg_bank[3][0]) begin
										program_counter <= {reg_bank[6], reg_bank[5], reg_bank[4]};
										state <= `FETCH;
									end
									else begin
										state <= `FETCH;
									end
								end
								2'b01: begin
									if (!reg_bank[3][0]) begin
										reg_bank[4] <= bus_data_in;
										program_counter <= program_counter + 1;	
									end
									else begin
										state <= `FETCH;
									end
								end
								2'b10: begin
									if (!reg_bank[3][1]) begin
										program_counter <= {reg_bank[6], reg_bank[5], reg_bank[4]};
										state <= `FETCH;
									end
									else begin 
										state <= `FETCH;
									end
								end
								2'b11: begin
						rogram_counte				reg_bank[4] <= bus_data_in;
										program_counter <= program_counter + 1;
									end
									else begin
										state <= `FETCH;
									end
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end
						
						`JNL: begin
							if (!reg_bank[3][3]) begin
								case (option)
									2'b00: begin
										program_counter <= {reg_bank[6], reg_bank[5], reg_bank[4]};
										state <= `FETCH;
									end
									2'b01: begin
										reg_bank[4] <= bus_data_in;
										program_counter <= program_counter + 1;
									end
									default: program_counter <= 12'b111111111111;
								endcase
							end
							else begin
								state <= `FETCH;
							end
						end

						default: state <= `FETCH;

					endcase
				end
				
				`STAGE_1: begin
					state <= `STAGE_2;

					case (opcode)
						`STO: begin
							case (option)
								2'b00: begin
									bus_data_out <= reg_bank[arg2];
									state <= `FETCH;
								end
								2'b01: begin
									reg_bank[5] <= bus_data_in;
									program_counter <= program_counter + 1;
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end

						`LD: begin
							case (option)
								2'b00: begin
									reg_bank[arg2] <= bus_data_in;
									state <= `FETCH;
								end
								2'b01: begin
									reg_bank[5] <= bus_data_in;
									program_counter <= program_counter + 1;
								end
								default: program_counter <= 12'b111111111111;
							endcase
						end

						`ADD_INC: begin
							case (option)
								2'b01: reg_bank[arg2] <= alu_o;
								default: reg_bank[arg1] <= alu_o;
							endcase
							reg_bank[3] <= alu_f;
							state <= `FETCH;
						end

						`ADC: begin
							reg_bank[arg1] <= alu_o;
							reg_bank[3] <= alu_f;
							state <= `FETCH;
						end
						
						`SUB_DEC: begin
							case (option)
								2'b00: reg_bank[arg1] <= alu_o;
								default: reg_bank[arg2] <= alu_o;
							endcase
							reg_bank[3] <= alu_f;
							state <= `FETCH;
						end

						`SBB: begin
							case (option)
								2'b00: reg_bank[arg1] <= alu_o;
								default: reg_bank[arg2] <= alu_o;
							endcase
							reg_bank[3] <= alu_f;
							state <= `FETCH;
						end
						
						`SHLR: begin
							reg_bank[arg2] <= alu_o;
							state <= `FETCH;
						end

						`NAND_NOR: begin
							case (option)
								2'b00: reg_bank[arg1] <= alu_o;
								2'b11: reg_bank[arg1] <= alu_o;
								default: reg_bank[arg2] <= alu_o;
							endcase
							reg_bank[3] <= alu_f;
							state <= `FETCH;
						end
						
						`AND_OR: begin
							case (option)
								2'b00: reg_bank[arg1] <= alu_o;
								2'b11: reg_bank[arg1] <= alu_o;
								default: reg_bank[arg2] <= alu_o;
							endcase
							reg_bank[3] <= alu_f;
							state <= `FETCH;
						end
						
						`XOR_NOT: begin
							case (option)
								2'b00: reg_bank[arg1] <= alu_o;
								default: reg_bank[arg2] <= alu_o;
							endcase
							state <= `FETCH;
						end

						`JMP: begin
							reg_bank[5] <= bus_data_in;
							program_counter <= program_counter + 1;
						end

						`JNZ: begin
							reg_bank[5] <= bus_data_in;
							program_counter <= program_counter + 1;
						end
						
						`JNC_JNB: begin
							reg_bank[5] <= bus_data_in;
							program_counter <= program_counter + 1;
						end
						
						`JNL: begin
							reg_bank[5] <= bus_data_in;
							program_counter <= program_counter + 1;
						end

						default: state <= `FETCH;
					endcase
				end

				`STAGE_2: begin
					state <= `STAGE_3;
					case (opcode)
						`STO: reg_bank[6] <= bus_data_in;
						`LD: reg_bank[6] <= bus_data_in;
						`JMP: reg_bank[6] <= bus_data_in;
						`JNZ: reg_bank[6] <= bus_data_in;
						`JNC_JNB: reg_bank[6] <= bus_data_in;
						`JNL: reg_bank[6] <= bus_data_in;
						default: program_counter <= 12'b111111111111;
					endcase
				end
					

				`STAGE_3: begin
					state <= `STAGE_4;

					case (opcode)
						`STO: begin
							bus_data_rw <= 1'b1;
							bus_addr <= {reg_bank[6], reg_bank[5], reg_bank[4]};
						end

						`LD: begin
							bus_addr <= {reg_bank[6], reg_bank[5], reg_bank[4]};
						end

						`JMP: begin
							program_counter <= {reg_bank[6], reg_bank[5], reg_bank[4]};
							state <= `FETCH;
						end

						`JNZ: begin
							program_counter <= {reg_bank[6], reg_bank[5], reg_bank[4]};
							state <= `FETCH;
						end
						
						`JNC_JNB: begin
							program_counter <= {reg_bank[6], reg_bank[5], reg_bank[4]};
							state <= `FETCH;
						end
						
						`JNL: begin
							program_counter <= {reg_bank[6], reg_bank[5], reg_bank[4]};
							state <= `FETCH;
						end

						default: state <= `FETCH;
					endcase
				end

				`STAGE_4: begin
					state <= `FETCH;

					case(opcode)
						`STO: bus_data_out <= reg_bank[arg2];
						`LD: reg_bank[arg2] <= bus_data_in;
						default: program_counter <= 12'b111111111111;
					endcase
				end
			endcase
		end
	end

endmodule
