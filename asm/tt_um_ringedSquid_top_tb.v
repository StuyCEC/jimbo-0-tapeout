`include "tt_um_ringedSquid_top.v"

module tt_um_ringedSquid_top_tb;
	reg clk;
	reg rst_n;
	reg ena;

	reg [7:0] ui_in;
	reg [7:0] uio_in;

	wire [7:0] uo_out;
	wire [7:0] uio_out;
	wire [7:0] uio_oe;

	wire [10:0] address_bus;
	wire rw;
	reg [3:0] data_bus_out;
	wire [3:0] data_bus_in;

	assign address_bus = {uo_out[6:0], uio_out[7:4]};
	assign rw = uo_out[7];
	assign data_bus_in = uo_out[3:0];

	//For the sim
	reg [10:0] check_address;
	reg [3:0] expected_value;

	reg [14:0] testvectors [2047:0];
	reg [31:0] vectornum;
	reg [31:0] errors;

	reg state;
	/*
	* 1 -> running program
	* 0 -> checking memory
	*/

	reg [3:0] ram [2047:0];

	tt_um_ringedSquid_top dut (
		.ui_in(ui_in),
		.uo_out(uo_out),
		.uio_in(uio_in),
		.uio_out(uio_out),
		.uio_oe(uio_oe),
		.ena(ena),
		.clk(clk),
		.rst_n(rst_n)
	);

	/*
	* A program loaded into memory for the CPU.
	* Then the cpu runs it and spits out some answer into memory,
	* the testbench then checks those addresses to see if it passes the
	* test
 	*/

	always begin
		clk = 1; #5;
		clk = 0; #5;
	end

	initial begin
		//load ram
		$readmemb("program.bin", ram, 0, 2047);
		$readmemh("program_checks.tv", testvectors, 0, 2047);
		vectornum = 0;
		errors = 0;
		state = 2;

		$dumpfile("tt_um_ringedSquid_top_tb.vcd");
		$dumpvars(0, dut);

		rst_n = 0; #27;
		rst_n = 1;
		state = 0;
	end

	always @(*) begin
		if (rst_n) begin
			if (state == 0) begin
				if (rw) begin
					ram[address_bus] = data_bus_in;
				end
				else begin
					data_bus_out = ram[address_bus];
					uio_in [3:0] = data_bus_out;
				end

				if (address_bus == 11'h7ff) begin
					state = 1;
				end
			end

			else if (state == 1) begin //Check memory addresses (well load them)
				check_address <= testvectors[vectornum][14:4];
				expected_value <= testvectors[vectornum][3:0];
			end
		end
	end

	always @(negedge clk) begin
		if (rst_n) begin
			if (state == 1) begin
				if (expected_value !== ram[check_address]) begin
					$display("ERROR: %h\t CASE: %h", errors, vectornum);
					$display("\tADDR: %h", check_address);
					$display("\t\tEXPECTED: %h\tACTUAL: %h", expected_value, ram[check_address]);
					$display("---------------------------------------------");
					errors = errors + 1;
				end
				vectornum = vectornum + 1;
				
				if (testvectors[vectornum] === 11'bx) begin
					$display("SUCCESS");
					$display("%d addresses checked with %d mismatches", vectornum, errors);
					$finish;
				end
			end
		end
	end

endmodule
