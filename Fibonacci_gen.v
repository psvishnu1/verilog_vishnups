`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Palakkad
// Engineer: Vishnu P S 
//////////////////////////////////////////////////////////////////////////////////

module fibonacci(input clk,input reset,output [3:0] fib_out);
  reg [3:0] num1,num2;
  always @(posedge clk)

  begin
    if (reset)
      begin
        num1<=0;
        num2<=1;
      end
    else begin
      num1<=num2;
      num2<=fib_out;
    end
  end
 adder ad1(num1,num2,fib_out);
endmodule


module FA(input a,b,cin,output cout,sum);
assign sum=a^b^cin;
assign cout=cin*(a^b)+a*b;
endmodule

module adder(input[3:0]A,B,output [4:0]SUM);
wire [4:0] carry;
assign carry[0] = 1'b0;
assign SUM[4] = carry[4];
genvar i;
generate
for (i=0;i<4;i=i+1)
begin : ripple
FA fa(A[i],B[i],carry[i],carry[i+1],SUM[i]);
end
endgenerate
endmodule
