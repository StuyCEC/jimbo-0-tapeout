`include "ALU.v"

`define MOV_R 	6'b000000
`define MOV_I 	6'b000001
`define STO_R 	6'b000100
`define STO_I 	6'b000101
`define LD_R  	6'b001000 
`define LD_I  	6'b001001
`define ADD_R 	6'b001101
`define ADD_I 	6'b001101
`define INC   	6'b001110
`define ADC_R 	6'b010000
`define ADC_I 	6'b010001
`define SUB_R 	6'b010100
`define SUB_R 	6'b010100
`define SUB_Y 	6'b010110
`define DEC   	6'b010111
`define SBB_R 	6'b011001
`define SBB_I 	6'b011001
`define SBB_Y 	6'b011001
`define SHL   	6'b011100
`define SHR     6'b011101
`define NAND_R  6'b100000
`define NAND_I  6'b100001
`define NOR_R   6'b100010
`define NOR_I  	6'b100011
`define AND_R   6'b100100
`define AND_I   6'b100101
`define OR_R   	6'b100110
`define OR_I   	6'b100111
`define XOR_R   6'b101000
`define XOR_I   6'b101001
`define NOT   	6'b101010
`define JMP_M  	6'b101100
`define JMP_I  	6'b101101
`define JNZ_M  	6'b110000
`define JNZ_I  	6'b110001
`define JNC_M  	6'b110100
`define JNC_I  	6'b110101
`define JNB_M  	6'b110110
`define JNB_I  	6'b110111
`define JNL_M  	6'b111000
`define JNL_I  	6'b111001
`define JNE_M  	6'b111010
`define JNE_I  	6'b111011
`define NOP  	6'b111100

module CPU (
	input wire clk,
	input wire reset,
	inout reg [3:0] bus_data,
	output reg [11:0] bus_addr
);
	reg bus_data_rw; //0 for r, 1 for w
	reg [3:0] bus_data_out;

	assign bus_data = bus_data_rw ? 4'hz : bus_data_out;

	reg [3:0] reg_a;
	reg [3:0] reg_b;
	reg [3:0] reg_f;
	reg [3:0] reg_addr_0;
	reg [3:0] reg_addr_1;
	reg [3:0] reg_addr_2;

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
	assign option = reg_instruction[7];
	assign arg1 = reg_instruction[6:4];
	assign arg2 = reg_instruction[3:0];

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
			reg_a = 4'b0000;
			reg_b = 4'b0000;
			reg_f = 4'b0000;
			reg_addr_0 = 4'b0000;
			reg_addr_1 = 4'b0000;
			reg_addr_2 = 4'b0000;
			
			alu_a = 4'b0000;
			alu_b = 4'b0000;
			alu_mode = 4'b0000;

			reg_instruction = 11'h0;
			program_counter = 11'h0;

			bus_addr = 11'h0;
			bus_data_rw = 1'b0;
			bus_data_out = 4'b0000;

		end else begin


		end
	end




endmodule
