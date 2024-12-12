`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Palakkad
// Engineer: Vishnu P S 
//////////////////////////////////////////////////////////////////////////////////

module RCA #(parameter WIDTH = 4)(
	output [WIDTH:0]   sum,
	input  [WIDTH-1:0] a, b,
	input  clk, rst, cin
);

	wire [WIDTH-1:0] a_reg, b_reg;
	wire [WIDTH:0] carry, sum_reg;

	// Input/Output registers
	register #(WIDTH) R_a   (.clk(clk), .rst(rst), .reg_in(a), .reg_out(a_reg));
	register #(WIDTH) R_b   (.clk(clk), .rst(rst), .reg_in(b), .reg_out(b_reg));
	register #(1)     R_cin (.clk(clk), .rst(rst), .reg_in(cin), .reg_out(cin_reg));

	register #(WIDTH+1) R_sum (.clk(clk), .rst(rst), .reg_in(sum_reg), .reg_out(sum));

	assign sum_reg[WIDTH] = carry[WIDTH];
	assign carry[0] = cin_reg;

	genvar i;
	generate
	for( i = 0; i < WIDTH; i = i + 1)
		begin:FAgen
			FA FA0(.A(a_reg[i]), .B(b_reg[i]), .Cin(carry[i]),  .S(sum_reg[i]), .Cout(carry[i+1]));	
		end
	endgenerate

//	FA FA0(.A(a_reg[0]), .B(b_reg[0]), .Cin(cin_reg),  .S(sum_reg[0]), .Cout(carry[0]));
//	FA FA1(.A(a_reg[1]), .B(b_reg[1]), .Cin(carry[0]), .S(sum_reg[1]), .Cout(carry[1]));
//	FA FA2(.A(a_reg[2]), .B(b_reg[2]), .Cin(carry[1]), .S(sum_reg[2]), .Cout(carry[2]));
//	FA FA3(.A(a_reg[3]), .B(b_reg[3]), .Cin(carry[2]), .S(sum_reg[3]), .Cout(carry[3]));
	

endmodule

module FA(
	output S, Cout,
	input  A, B, Cin
);

	assign S    = A ^ B ^ Cin;
	assign Cout = A&B | (A|B)&Cin;

endmodule

module register#(parameter WIDTH = 4) (
	output reg [WIDTH-1:0] reg_out,
	input [WIDTH-1:0] reg_in,
	input clk, rst
);

	always @ (posedge clk)
	if( !rst )
		reg_out <= 0;
	else
		reg_out <= reg_in;

endmodule
