// GCD Finder

// GCD Top
module gcd_top(
    input [5:0] A_in,B_in,
    input clk,reset,op_valid,ack,
    output gcd_valid,
    output [5:0] gcd
);

wire [1:0] A_mux_sel;
wire B_mux_sel,A_en,B_en,A_lt_B,b_eq_0;

gcd_datapath D1(.A_in(A_in), .B_in(B_in), .clk(clk), .A_en(A_en), .B_en(B_en), .A_mux_sel(A_mux_sel), .B_mux_sel(B_mux_sel), .gcd(gcd), .A_lt_B(A_lt_B), .b_eq_0(b_eq_0));

gcd_controlpath C1(.clk(clk), .reset(reset), .ack(ack), .b_eq_0(b_eq_0), .A_lt_B(A_lt_B), .op_valid(op_valid), .A_mux_sel(A_mux_sel), .B_mux_sel(B_mux_sel), .gcd_valid(gcd_valid), .A_en(A_en), .B_en(B_en));

endmodule

// GCD Datapath

module gcd_datapath(
        input [5:0] A_in,B_in,
        input clk,A_en,B_en,
        input [1:0] A_mux_sel,
        input B_mux_sel,
        output [5:0] gcd,
        output A_lt_B,b_eq_0
);

wire [5:0] A_mux_out,B_mux_out,sub_out;

reg [5:0] A,B;

assign A_mux_out = A_mux_sel[1] ? B : A_mux_sel[0] ? sub_out : A_in;
assign B_mux_out = B_mux_sel ? A : B_in;
assign sub_out = A - B;
assign b_eq_0 = ( B == 5'b0);
assign A_lt_B = ( A < B ); 
assign gcd = b_eq_0 ? A : 0;

always @(posedge clk)
begin
if (A_en)
A <= A_mux_out;
if (B_en)
B <= B_mux_out;
end

endmodule

// GCD Controlpath

module gcd_controlpath(
            input clk,reset,ack,b_eq_0,A_lt_B,op_valid,
            output reg [1:0] A_mux_sel,
            output reg B_mux_sel, A_en, B_en,
            output gcd_valid
);

parameter IDLE = 2'b00;
parameter BUSY = 2'b01;
parameter DONE = 2'b10;

reg [1:0] state = 2'b0;
reg [1:0] next_state;

always @(*)
begin
case (state)
IDLE:
begin
A_mux_sel = 2'b00;
B_mux_sel = 1'b0;
A_en = 1'b1;
B_en = 1'b1;
if (op_valid)
  next_state = BUSY;
end
BUSY:
begin
if(b_eq_0)
next_state = DONE ;
if(A_lt_B)
begin
A_mux_sel = 2'b10;
B_mux_sel = 1'b1;
A_en = 1'b1;
B_en = 1'b1;
end
else
begin
A_mux_sel = 2'b01;
A_en = 1'b1;
B_en = 1'b0;
end
end
DONE:
begin
A_en = 1'b0;
B_en = 1'b0;
if(ack)
next_state = IDLE;
end
default:
next_state = IDLE;
endcase
end

always @(posedge clk or posedge reset)
begin
if (reset)
state <= IDLE;
else
state <= next_state;
end

assign gcd_valid = (state[1]);

endmodule