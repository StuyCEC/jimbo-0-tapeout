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
    assign rw = uo_out[7];  // rw = 1 -> write, rw = 0 -> read
    assign data_bus_in = uio_out[3:0];  // Input data from uio_out to RAM

    //For the sim
    reg [10:0] check_address;
    reg [3:0] expected_value;

    reg [14:0] testvectors [2048:0];
    reg [31:0] vectornum;
    reg [31:0] errors;

    reg state; // State machine for memory check (1 -> checking memory, 0 -> running program)

    reg [3:0] ram [2047:0]; // RAM definition (4-bit wide, 2048 locations)

    // Instantiate the top-level DUT
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

    // Clock generation
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // Initial setup and program loading
    initial begin
        // Load test program and test vectors
        $readmemb("program.bin", ram, 0, 2047);  // Load program into RAM
        $readmemh("program_checks.tv", testvectors, 0, 2047);  // Load test vectors

        vectornum = 0;
        errors = 0;
        state = 0;  // Initially, we're running the program

		data_bus_out = 4'b0000;

        $dumpfile("tt_um_ringedSquid_top_tb.vcd");
        $dumpvars(0, dut);

        // Reset logic
        rst_n = 0; #27;
        rst_n = 1;
    end

    // RAM read/write logic (handled combinationally)
    always @(*) begin
        if (rst_n && (state == 0)) begin
            if (rw) begin
                // Writing to RAM
                //$display("Writing to RAM: Address = %h, Data = %h", address_bus, data_bus_in);
                ram[address_bus] <= data_bus_in;
            end else begin
                // Reading from RAM
                data_bus_out <= ram[address_bus];
                uio_in[3:0] <= data_bus_out; // Send data to uio_in
                //$display("Reading from RAM: Address = %h, Data = %h", address_bus, data_bus_out);
            end
        end
    end

    // Test vector checking (sequentially on the rising edge of the clock)
    always @(posedge clk) begin
        if (rst_n && (state == 1)) begin
            // Extract the check address and expected value from test vectors
            check_address = testvectors[vectornum][14:4];
            expected_value = testvectors[vectornum][3:0];

            // Display the current test vector for debugging
            $display("Checking Address: %h, Expected: %h", check_address, expected_value);

            // Check if the value in RAM matches the expected value
            if (expected_value !== ram[check_address]) begin
                $display("ERROR: %d\t Case: %d", errors, vectornum);
                $display("\tADDR: %h", check_address);
                $display("\t\tEXPECTED: %h\tACTUAL: %h", expected_value, ram[check_address]);
                $display("---------------------------------------------");
                errors = errors + 1;
            end
            vectornum = vectornum + 1;

            // Check if we have finished all test vectors
            if (testvectors[vectornum] === 15'bx) begin
                $display("SUCCESS: %d addresses checked with %d mismatches", vectornum, errors);
                $finish;
            end
        end
    end

    // State transitions for checking memory (after program finishes)
    always @(negedge clk) begin
        if (rst_n && (state == 0) && (address_bus == 11'h7ff)) begin
            state = 1;  // Transition to memory checking state
        end
    end

endmodule
