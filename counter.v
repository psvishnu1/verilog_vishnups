// `timescale <time_unit>/<time_precision>
`timescale 1ns / 1ns

module counter
(
 input clk, m, rst,
 output reg [7:0] count
);

	wire [7:0] count_mux_out;
	wire [7:0] rst_mux_out;

	// Combinational logic
	assign count_mux_out = m ? count + 8'b1 : count - 8'b1;	// m = 1 -> up-counter; m = 0 -> down-counter
	assign rst_mux_out = rst ? count_mux_out : 8'b0;		// active-low reset

	// Sequential logic
	always @(posedge clk or negedge rst)
	begin
		count <= rst_mux_out;
	end

endmodule

