// Top module

module sum_to_N_top(
  	input clk,N_valid,reset,ack,
 		input [2:0] N,
  	output sum_valid,
  	output [4:0] sum
);

  wire i_eq_1;
  wire [1:0] state;
  
  datapath data1(.N(N),.state(state),.clk(clk),
                  .sum(sum),.i_eq_1(i_eq_1));
  controlpath control1(.N_valid(N_valid), .reset(reset),
               .ack(ack), .clk(clk), .i_eq_1(i_eq_1), 
               .state(state), .sum_valid(sum_valid));

endmodule

// Datapath

module datapath(
  		input [2:0] N,
  		input [1:0] state,
  		input clk,
 			output reg [4:0]sum,
  		output i_eq_1
);
  
  wire [4:0] add_out;
  wire [2:0] i_mux_out;
  wire [4:0] sum_mux_out;
  
  reg [2:0] i;
  
  assign i_mux_out = state[1] ? i : state[0] ? i-1 : N;
  assign sum_mux_out = state[1] ? sum : state[0] ? add_out : 0;
  assign add_out = i + sum;
  assign i_eq_1 = (i==1);
  
  always @(posedge clk)
    begin
      i <= i_mux_out;
      sum <= sum_mux_out;
    end  
  
endmodule

// Control Path

module controlpath(N_valid, reset, ack, clk, i_eq_1, state, sum_valid);

input N_valid, ack, clk, i_eq_1, reset;
output [1:0] state;
output sum_valid;

localparam idle = 2'b00;
localparam busy = 2'b01;
localparam done = 2'b10;

reg [1:0] state = 2'b0;
reg [1:0] next_state;

always @(*)
begin
  case (state)
	idle:
	  if (N_valid)
       	     next_state = busy;
    busy:
      if(i_eq_1)
            next_state = done ;
    done:
      if (ack)
            next_state = idle;
    default:
            next_state = idle;
endcase
end

  always @(posedge clk or posedge reset)
begin
  if (reset)
    state <= idle;
  else
  	state <= next_state;
end
  
  assign sum_valid = (state[1]);
  
endmodule