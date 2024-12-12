// Cordic Top

module cordic_top
(
    input signed [15:0] x_in, y_in,
  	input signed [15:0] theta_in,
    input theta_valid, clk,reset,ack,
  	output signed [15:0] sin_theta, cos_theta,
  	output output_valid
 );
  
  wire x_mux_sel, y_mux_sel, theta_mux_sel, xi_en, yi_en, theta_en, i_eq_max, counter_reset;
  
  cordic_datapath data1(.x_in(x_in),
                        .y_in(y_in),
                        .theta_in(theta_in),
                        .clk(clk),
                        .reset(reset),
                        .i_eq_max(i_eq_max),
                        .xi_en(xi_en),
                        .yi_en(yi_en),
                        .theta_en(theta_en),
                        .counter_reset(counter_reset),
                        .x_mux_sel(x_mux_sel),
                        .y_mux_sel(y_mux_sel),
                        .theta_mux_sel(theta_mux_sel),
                        .sin_theta(sin_theta),
                        .cos_theta(cos_theta));
  
  cordic_controlpath control1(.theta_valid(theta_valid),
                              .output_valid(output_valid),
                              .x_mux_sel(x_mux_sel),
                              .y_mux_sel(y_mux_sel),
                              .theta_mux_sel(theta_mux_sel),
                              .xi_en(xi_en),
                        	  .yi_en(yi_en),
                        	  .theta_en(theta_en),
                              .counter_reset(counter_reset),
                              .i_eq_max(i_eq_max),
                              .clk(clk),
                              .reset(reset),
                              .ack(ack)
);
 
endmodule
  


// Data path

module cordic_datapath
(
	input signed [15:0] x_in, y_in, theta_in,
    input clk, reset, x_mux_sel, y_mux_sel, theta_mux_sel,counter_reset,
    output i_eq_max,xi_en,yi_en,theta_en,
  	output signed [15:0] sin_theta, cos_theta
);
  
  wire signed [15:0] x_mux_out, y_mux_out, x_add_out, y_add_out, y_shift_out, x_shift_out, theta_mux_out, theta_add_out;
  wire [3:0] i;
  reg signed [15:0] theta_LUT;
  reg signed [15:0] xi,yi,theta;
  
  counter count1(.clk(clk),
                 .counter_reset(counter_reset),
                 .count(i));
  
  barrel_shifter xshift(.shift_in(xi),
                        .shift_out(x_shift_out),
                        .select(i));
  
  barrel_shifter yshift(.shift_in(yi),
                        .shift_out(y_shift_out),
                        .select(i));
  
  assign x_mux_out = x_mux_sel ? x_in : x_add_out;
  assign y_mux_out = y_mux_sel ? y_in : y_add_out;
  assign theta_mux_out = theta_mux_sel ? theta_in : theta_add_out;
  assign i_eq_max = ( i == 4'd15 );
  assign x_add_out = theta[15] ? xi + y_shift_out : xi - y_shift_out;
  assign y_add_out = theta[15] ? yi - x_shift_out : yi + x_shift_out;
  assign theta_add_out = theta[15] ? theta + theta_LUT : theta - theta_LUT;
  assign sin_theta = yi;
  assign cos_theta = xi;
  
  always @(*)
    begin
      case (i-1)
        4'd0: theta_LUT = 16'h3244;
		4'd1: theta_LUT = 16'h1dac;
        4'd2: theta_LUT = 16'h0fae;
        4'd3: theta_LUT = 16'h07f5;
        4'd4: theta_LUT = 16'h03ff;
        4'd5: theta_LUT = 16'h0200;
        4'd6: theta_LUT = 16'h0100;
        4'd7: theta_LUT = 16'h0080;
        4'd8: theta_LUT = 16'h0040;
        4'd9: theta_LUT = 16'h0020;
        4'd10: theta_LUT = 16'h0010;
        4'd11: theta_LUT = 16'h0008;
        4'd12: theta_LUT = 16'h0004;
        4'd13: theta_LUT = 16'h0002;
        4'd14: theta_LUT = 16'h0001;
        4'd15: theta_LUT = 16'h0000;
        default: theta_LUT = 16'h3244;
      endcase
    end
  
  always @(posedge clk)
    begin
      if(xi_en)
      	xi <= x_mux_out;
      if(yi_en)
      	yi <= y_mux_out;
      if(theta_en)
      	theta = theta_mux_out;
    end

endmodule

// Barrel shifter
module barrel_shifter
(
	input signed [15:0] shift_in,
	input [3:0] select,
	output reg signed [15:0] shift_out
);
   
  always @(*)
    begin
      case (select-1)
        4'd0: shift_out = shift_in;
        4'd1: shift_out = shift_in >>> 1;
        4'd2: shift_out = shift_in >>> 2;
        4'd3: shift_out = shift_in >>> 3;
        4'd4: shift_out = shift_in >>> 4;
        4'd5: shift_out = shift_in >>> 5;
        4'd6: shift_out = shift_in >>> 6;
        4'd7: shift_out = shift_in >>> 7;
        4'd8: shift_out = shift_in >>> 8;
        4'd9: shift_out = shift_in >>> 9;
        4'd10: shift_out = shift_in >>> 10;
        4'd11: shift_out = shift_in >>> 11;
        4'd12: shift_out = shift_in >>> 12;
        4'd13: shift_out = shift_in >>> 13;
        4'd14: shift_out = shift_in >>> 14;
        4'd15: shift_out = shift_in >>> 15;
        default: shift_out = shift_in;
      endcase
    end
    
endmodule

    
// Up counter
module counter
( 
    input clk,counter_reset,
    output reg [3:0] count
);

  always@(posedge clk or negedge counter_reset)
    begin
        if(counter_reset)
  		    count <= 0;
  	 else
  		    count <= count + 1;
    end
    
endmodule
    

// Control path    
module cordic_controlpath
(
    input clk, reset, ack, i_eq_max, theta_valid,
    output output_valid,
    output reg x_mux_sel, y_mux_sel, theta_mux_sel, counter_reset, xi_en, yi_en, theta_en
);    
  
  parameter IDLE = 2'b00;
  parameter BUSY = 2'b01;
  parameter DONE = 2'b10;
  
  reg [1:0] state = 2'b00;
  reg [1:0] nextstate;
  
  always @(*)
    begin
      case (state)
        IDLE:
          if (theta_valid)
            nextstate = BUSY;
        BUSY:
          if (i_eq_max)
            nextstate = DONE;
        DONE:
          if (ack)
            nextstate = IDLE;
        default:
          nextstate = IDLE;
      endcase
    end
  
  always @(*)
    begin
      case (state)
        IDLE:
          begin
              x_mux_sel = 1;
              y_mux_sel = 1;
              theta_mux_sel = 1;
              xi_en = 1;
              yi_en = 1;
              theta_en = 1;
              counter_reset = 0;
              if (theta_valid)
              begin
                 counter_reset = 1;
              end
          end
            
        BUSY:
          begin
              x_mux_sel = 0;
              y_mux_sel = 0;
              theta_mux_sel = 0;
              xi_en = 1;
              yi_en = 1;
              theta_en = 1;
              counter_reset = 0;
          end
        
        DONE:
          begin
              xi_en = 0;
              yi_en = 0;
              theta_en = 0;
              counter_reset = 0;
          end
        
      endcase
    end
        
  
  always @(posedge clk or posedge reset)
    begin
      if (reset)
        state <= IDLE;
      else
        state <= nextstate;
    end
  
  assign output_valid = (state == DONE);
  
endmodule
  

