module test;
	reg[3:0] a, b, c;
	reg borrow;
	initial a = 4'b1100;
	initial b = 4'b0000;

	always @(*) begin
		{borrow, c} = b - a;
		$display("%b, %b", borrow, c);

	end
endmodule
