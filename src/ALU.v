module ALU (
	input wire [3:0] a,
	input wire [3:0] b,
	input wire [3:0] mode,

	input wire carry_f,
	input wire borrow_f,

	output reg [3:0] c,
	output reg [3:0] flags
);

	always @(*) begin
		case (mode)
			4'b0000: c = a + b;
			4'b0001: {flags[0], c} = a + b + carry_f;
			4'b0010: c = a - b;
			4'b0011: {flags[1], c} = a - b - borrow_f;
			4'b0011: c = a << 1;
			4'b0100: c = a >> 1;
			4'b0101: c = a & b;
			4'b0110: c = a | b;
			4'b0111: c = ~(a);
			4'b1000: c = a ^ b;
			4'b1001: c = ~(a & b);
			4'b1010: c = ~(a | b);
			4'b1011: c = a + 1;
			4'b1100: c = a - 1;
			default: c = 4'b0000;
		endcase

		flags[2] = (c == 4'b0000);
		flags[3] = (a < b);

	end

endmodule
