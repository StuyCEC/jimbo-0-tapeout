/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_ringedSquid_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire uio_rw;
  wire [11:0] bus_addr;

  assign uio_oe[7:4] = 4'b1111;
  assign uio_oe [3:0] = {4{uio_rw}};
  assign bus_addr = {uo_out[7:0], uio_out[7:4]};

	CPU cpu (
		.clk(clk),
		.rst_n(rst_n),
		.bus_data_in(uio_in[3:0]),
    .bus_data_rw(uio_rw),
    .bus_data_out(uio_out[3:0]),
    .bus_addr(bus_addr)
	);

  // List all unused inputs to prevent warnings
  wire _unused = &{ui_in[7:0], ena, 1'b0};

endmodule
