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
`define STAGE_1 1
`define STAGE_2 2
`define STAGE_3 3
`define STAGE_4 4

module CPU (
	input wire clk,
	input wire rst_n,
	input wire [3:0] bus_data_in,
	output reg bus_data_rw,
	output reg [3:0] bus_data_out,
	output reg [10:0] bus_addr
);

	reg [4:0] state;
	reg [3:0] fetch_state;

	reg [3:0] reg_bank [0:7];
    reg [3:0] temp_flags;

	reg [3:0] alu_a;
	reg [3:0] alu_b;
	reg [3:0] alu_mode;

	wire [3:0] alu_o;
	wire [3:0] alu_f;
	
	reg [3:0] alu_f_buff;

	reg [11:0] reg_instruction;
	reg [10:0] program_counter;

	wire [3:0] opcode;
	wire [1:0] option;
	wire [2:0] arg1;
	wire [2:0] arg2;

	/* debug */
	wire [11:0] add_reg;
	wire [3:0] reg0;
	wire [3:0] reg1;
	wire [3:0] reg2;
	wire [3:0] reg3;
	wire [3:0] reg4;
	wire [3:0] reg5;
	wire [3:0] reg6;

	assign add_reg = {reg_bank[6], reg_bank[5], reg_bank[4]};

	assign reg0 = reg_bank[0];
	assign reg1 = reg_bank[1];
	assign reg2 = reg_bank[2];
	assign reg3 = reg_bank[3];
	assign reg4 = reg_bank[4];
	assign reg5 = reg_bank[5];
	assign reg6 = reg_bank[6];
	

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
			program_counter <= 11'h0;

			bus_addr <= 11'h0;
			bus_data_rw <= 1'b0;
			bus_data_out <= 4'b0000;

			temp_flags <= 4'b0000;

		end else begin
            case (state)
                `FETCH: begin
                    case(fetch_state)
                        0: begin
                            bus_data_rw <= 1'b0;
                            bus_addr <= program_counter;
                        end
                        1: bus_addr <= program_counter;
                        2: bus_addr <= program_counter;
						default: ;
                    endcase
                end
                `STAGE_1: begin
                    case (opcode)
                        `MOV: begin
                            case (option)
								2'b01: bus_addr <= program_counter;
                                default: reg_bank[arg2] <= reg_bank[arg1];
                            endcase
                        end
                        `STO: begin
                            case (option)
								2'b01: bus_addr <= program_counter;
								default: begin
									bus_data_rw <= 1'b1;
									bus_addr <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
                                end
							endcase
                        end
                        `LD: begin
							case (option)
								default: begin
                                    bus_data_rw <= 1'b0;
                                    bus_addr <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
                                end
								2'b01: bus_addr <= program_counter;
							endcase
						end
						`ADD_INC: begin
							alu_mode <= 4'b0000;
							case (option)
								default: begin
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: alu_b <= reg_bank[arg2];
								2'b10: begin
									alu_a <= 4'b0001;
									alu_b <= reg_bank[arg2];
								end
							endcase
						end
						`ADC: begin
							alu_mode <= 4'b0001;
							case (option)
								default: begin
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_b <= reg_bank[arg2];
								end
							endcase
						end	
						`SUB_DEC: begin
							alu_mode <= 4'b0010;
							case (option)
								default: begin
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_b <= reg_bank[arg2];
								end
								2'b10: begin
									alu_a <= reg_bank[arg2];
								end
								2'b11: begin
									alu_b <= 4'b0001;
									alu_a <= reg_bank[arg2];
								end
							endcase
						end
						`SBB: begin
							alu_mode <= 4'b0011;
							case (option)
								default: begin
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_b <= reg_bank[arg2];
								end
								2'b10: begin
									alu_a <= reg_bank[arg2];
								end
							endcase
						end
						`SHLR: begin
							case (option)
								default: begin
									alu_mode <= 4'b0100;
									alu_a <= reg_bank[arg2];
								end
								2'b01: begin
									alu_mode <= 4'b0101;
									alu_a <= reg_bank[arg2];
								end
							endcase
						end
						`NAND_NOR: begin
							case (option)
								default: begin
									alu_mode <= 4'b1010;
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_mode <= 4'b1010;
									alu_b <= reg_bank[arg2];
								end
								2'b10: begin
									alu_mode <= 4'b1011;
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b11: begin
									alu_mode <= 4'b1011;
									alu_b <= reg_bank[arg2];
								end
							endcase
						end
						`AND_OR: begin
							case (option)
								default: begin
									alu_mode <= 4'b0110;
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_mode <= 4'b0110;
									alu_b <= reg_bank[arg2];
								end
								2'b10: begin
									alu_mode <= 4'b0111;
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b11: begin
									alu_mode <= 4'b0111;
									alu_b <= reg_bank[arg2];
								end
							endcase
							state <= `STAGE_1;
						end
						`XOR_NOT: begin
							case (option)
								default: begin
									alu_mode <= 4'b1001;
									alu_a <= reg_bank[arg1];
									alu_b <= reg_bank[arg2];
								end
								2'b01: begin
									alu_mode <= 4'b1001;
									alu_b <= reg_bank[arg2];
								end
								2'b10: begin
                                    alu_mode <= 4'b1000;
                                    alu_a <= reg_bank[arg2];
                                end
							endcase
						end
						`JMP: begin
							case (option)
								default: program_counter <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
								2'b01: bus_addr <= program_counter;
							endcase
						end
						`JNZ: begin
							if (!reg_bank[3][2]) begin
								case (option)
									default: program_counter <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
									2'b01: bus_addr <= program_counter;
								endcase
							end
						end
						`JNC_JNB: begin
							case (option)
								default: begin
									if (!reg_bank[3][0]) begin
										program_counter <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
									end
								end
								2'b01: ;
								2'b10: begin
									if (!reg_bank[3][1]) begin
										program_counter <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
									end
								end
								2'b11: bus_addr <= program_counter;
							endcase
						end
						`JNL: begin
							if (!reg_bank[3][3]) begin
								case (option)
									default: program_counter <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
									2'b01: bus_addr <= program_counter;
								endcase
							end
						end
                        default: ;
                    endcase
                end

                `STAGE_2: begin
                    bus_addr <= program_counter;
                end

                `STAGE_3: begin
                    bus_addr <= program_counter;
                end

                `STAGE_4: begin
                    case (opcode) 
                        `STO: begin
							bus_addr <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
						end
                        `LD: bus_addr <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
                        default: ;
                    endcase
                end
            endcase
        end
        
    end
    always @(negedge clk) begin
        if (rst_n) begin
            case (state)
                `FETCH: begin
                    case(fetch_state)
                        0: begin
                            reg_instruction[11:8] <= bus_data_in;
                            program_counter <= program_counter + 1;
                            fetch_state <= 1;
                        end
                        1: begin
                            reg_instruction[7:4] <= bus_data_in;
                            program_counter <= program_counter + 1;
                            if (
								(opcode == `JMP) ||
								(opcode == `JNZ) ||
								(opcode == `JNC_JNB) ||
								(opcode == `JNL)
							)
							begin
								fetch_state <= 0;
								state <= `STAGE_1;
							end
                            else begin
                                fetch_state <= 2;
                            end
                        end
                        2: begin
                            reg_instruction[3:0] <= bus_data_in;
                            program_counter <= program_counter + 1;
                            fetch_state <= 0;
                            state <= `STAGE_1;
                        end
						default: ;
                    endcase
                end
                `STAGE_1: begin
                    case (opcode)
                        `MOV: begin
                            case (option)
                                2'b01: begin
                                    reg_bank[arg2] <= bus_data_in;
                                    program_counter <= program_counter + 1;
                                end
                                default: ;
                            endcase
                            state <= `FETCH;
                        end
                        `STO: begin
                            case (option)
                                default: begin
                                    bus_data_out <= reg_bank[arg2];
                                    state <= `FETCH;
                                end
								2'b01: begin
                                    reg_bank[6] <= bus_data_in;
                                    program_counter <= program_counter + 1;
                                    state <= `STAGE_2;
                                end
							endcase
                        end
                        `LD: begin
                            case (option)
                                default: begin
                                    reg_bank[arg2] <= bus_data_in;
                                    state <= `FETCH;
                                end
                                2'b01: begin
                                    reg_bank[6] <= bus_data_in;
                                    program_counter <= program_counter + 1;
                                    state <= `STAGE_2;
                                end
                            endcase
                        end
                        `ADD_INC: begin
							case (option)
								default: begin
									reg_bank[arg1] <= alu_o;
                                    temp_flags <= alu_f;  // Store ALU flags temporarily
        							reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                                    state <= `FETCH;
								end
								2'b01: begin
									alu_a <= bus_data_in;
									state <= `STAGE_2;
								end
                                2'b10: begin
									reg_bank[arg2] <= alu_o;
                                    temp_flags <= alu_f;  // Store ALU flags temporarily
       							 	reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                                    state <= `FETCH;
								end
							endcase
						end
                        `ADC: begin
							case (option)
								default: begin
									reg_bank[arg1] <= alu_o;
                                    temp_flags <= alu_f;  // Store ALU flags temporarily
        							reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                                    state <= `FETCH;
								end
								2'b01: begin
									alu_a <= bus_data_in;
									state <= `STAGE_2;
								end
							endcase
						end
                        `SUB_DEC: begin
							case (option)
								default: begin
									reg_bank[arg1] <= alu_o;
                                    temp_flags <= alu_f;  // Store ALU flags temporarily
        							reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                                    state <= `FETCH;
								end
								2'b01: begin
									alu_a <= bus_data_in;
									state <= `STAGE_2;
								end
								2'b10: begin
									alu_b <= bus_data_in;
									state <= `STAGE_2;
								end
                                2'b11: begin
									reg_bank[arg2] <= alu_o;
                                    temp_flags <= alu_f;  // Store ALU flags temporarily
        							reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                                    state <= `FETCH;
								end
							endcase
						end
                        `SBB: begin
							case (option)
								default: begin
									reg_bank[arg1] <= alu_o;
                                    temp_flags <= alu_f;  // Store ALU flags temporarily
        							reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                                    state <= `FETCH;
								end
								2'b01: begin
									alu_a <= bus_data_in;
									state <= `STAGE_2;
								end
								2'b10: begin
									alu_b <= bus_data_in;
									state <= `STAGE_2;
								end
							endcase
						end
                        `SHLR: begin
							reg_bank[arg2] <= alu_o;
                            temp_flags <= alu_f;  // Store ALU flags temporarily
        					reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                            state <= `FETCH;
						end
                        `NAND_NOR: begin
                            case (option)
								default: begin
									reg_bank[arg1] <= alu_o;
                                    temp_flags <= alu_f;  // Store ALU flags temporarily
        							reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                                    state <= `FETCH;
								end
								2'b01: begin
                                    alu_a <= bus_data_in;
                                    state <= `STAGE_2;
								end
								2'b11: begin
                                    alu_a <= bus_data_in;
                                    state <= `STAGE_2;
								end
                            endcase
                        end
                        `AND_OR: begin
                            case (option)
								default: begin
									reg_bank[arg1] <= alu_o;
                                    temp_flags <= alu_f;  // Store ALU flags temporarily
        							reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                                    state <= `FETCH;
								end
								2'b01: begin
                                    alu_a <= bus_data_in;
                                    state <= `STAGE_2;
								end
								2'b11: begin
                                    alu_a <= bus_data_in;
                                    state <= `STAGE_2;
								end
                            endcase
                        end
                        `XOR_NOT: begin
							alu_mode <= 4'b0000;
							case (option)
								default: begin
									reg_bank[arg1] <= alu_o;
                                    temp_flags <= alu_f;  // Store ALU flags temporarily
        							reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                                    state <= `FETCH;
								end
								2'b01: begin
									alu_a <= bus_data_in;
									state <= `STAGE_2;
								end
                                2'b10: begin
									reg_bank[arg2] <= alu_o;
                                    temp_flags <= alu_f;  // Store ALU flags temporarily
        							reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                                    state <= `FETCH;
								end
							endcase
						end
                        `JMP: begin
							case (option)
								default: state <= `FETCH;
								2'b01: begin
									reg_bank[6] <= bus_data_in;
									program_counter <= program_counter + 1;
                                    state <= `STAGE_2;
								end
							endcase
						end
                        `JNZ: begin
							if (!reg_bank[3][2]) begin
								case (option)
									default: state <= `FETCH;
									2'b01: begin
                                        reg_bank[6] <= bus_data_in;
                                        program_counter <= program_counter + 1;
                                        state <= `STAGE_2;
                                    end
								endcase
							end
                            else begin
                                state <= `FETCH;
                            end
						end
                        `JNC_JNB: begin
							case (option)
								default: state <= `FETCH;
								2'b01: begin
                                    if (!reg_bank[3][0]) begin
                                        reg_bank[6] <= bus_data_in;
                                        program_counter <= program_counter + 1;
                                        state <= `STAGE_2;
                                    end
                                    else begin
                                        state <= `FETCH;
                                    end
                                end
								2'b11: begin
                                    if (!reg_bank[3][1]) begin
                                        reg_bank[6] <= bus_data_in;
                                        program_counter <= program_counter + 1;
                                        state <= `STAGE_2;
                                    end
                                    else begin
                                        state <= `FETCH;
                                    end
                                end
							endcase
						end
                        `JNL: begin
							if (!reg_bank[3][3]) begin
								case (option)
									default: state <= `FETCH;
									2'b01: begin
                                        reg_bank[6] <= bus_data_in;
                                        program_counter <= program_counter + 1;
                                        state <= `STAGE_2;
                                    end
								endcase
							end
                            else begin
                                state <= `FETCH;
                            end
						end
                        default: state <= `FETCH;
                    endcase
                end
                `STAGE_2: begin
                    case (opcode)
                        `STO: begin
                            reg_bank[5] <= bus_data_in;
                            program_counter <= program_counter + 1;
                            state <= `STAGE_3;
                        end
                        `LD: begin
							reg_bank[5] <= bus_data_in;
                            program_counter <= program_counter + 1;
                            state <= `STAGE_3;
                        end
                        `ADD_INC: begin
							reg_bank[arg1] <= alu_o;
                            temp_flags <= alu_f;  // Store ALU flags temporarily
        					reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                            state <= `FETCH;
						end
						`ADC: begin
							reg_bank[arg1] <= alu_o;
                            temp_flags <= alu_f;  // Store ALU flags temporarily
        					reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                            state <= `FETCH;
						end	
						`SUB_DEC: begin
							reg_bank[arg1] <= alu_o;
                            temp_flags <= alu_f;  // Store ALU flags temporarily
        					reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                            state <= `FETCH;
						end
						`SBB: begin
							reg_bank[arg1] <= alu_o;
                            temp_flags <= alu_f;  // Store ALU flags temporarily
        					reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                            state <= `FETCH;
						end
						`NAND_NOR: begin
							reg_bank[arg1] <= alu_o;
                            temp_flags <= alu_f;  // Store ALU flags temporarily
        					reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                            state <= `FETCH;
						end
						`AND_OR: begin
							reg_bank[arg1] <= alu_o;
                            temp_flags <= alu_f;  // Store ALU flags temporarily
        					reg_bank[3] <= temp_flags;  // Update flags after one cycle delay
                            state <= `FETCH;
						end
						`JMP: begin
							reg_bank[5] <= bus_data_in;
                            program_counter <= program_counter + 1;
                            state <= `STAGE_3;
						end
						`JNZ: begin
							reg_bank[5] <= bus_data_in;
                            program_counter <= program_counter + 1;
                            state <= `STAGE_3;
						end
						`JNC_JNB: begin
							reg_bank[5] <= bus_data_in;
                            program_counter <= program_counter + 1;
                            state <= `STAGE_3;
						end
						`JNL: begin
							reg_bank[5] <= bus_data_in;
                            program_counter <= program_counter + 1;
                            state <= `STAGE_3;
						end
                        default: ;
                    endcase
                end

                `STAGE_3: begin
						reg_bank[4] <= bus_data_in;
                        program_counter <= program_counter + 1;
                        state <= `STAGE_4;
                end

                `STAGE_4: begin
                    case (opcode)
                        `STO: begin
							bus_data_rw <= 1'b1;
							bus_data_out <= reg_bank[arg2];
						end
                        `LD: reg_bank[arg2] <= bus_data_in;
						`JMP: program_counter <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
						`JNZ: program_counter <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};	
						`JNC_JNB: program_counter <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
						`JNL: program_counter <= {reg_bank[6][2:0], reg_bank[5], reg_bank[4]};
                        default: ;
                    endcase
					//$display("%h, %h, %h", reg_bank[6], reg_bank[5], reg_bank[4]);
					state <= `FETCH;
                end
            endcase
        end
    end
endmodule