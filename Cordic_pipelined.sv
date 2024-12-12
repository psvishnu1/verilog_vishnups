// Cordic Top

module cordic_top(
  					input signed [15:0] x_in, y_in,
  					input signed [15:0] theta_in,
                    input clk,reset,mode,
  					output signed [15:0] sin_theta, cos_theta, theta_final);
  
  wire signed [15:0] x_out [16:0];
  wire signed [15:0] y_out [16:0];
  wire signed [15:0] theta_out [16:0];
  reg signed [15:0] x_last, y_last, theta_last;
  parameter signed [15:0] theta_LUT [0:15] = {16'h3244, 16'h1dac, 16'h0fae, 
                                              16'h07f5, 16'h03ff, 16'h0200,
                                              16'h0100, 16'h0080, 16'h0040,
                                              16'h0020, 16'h0010, 16'h0008,
                                              16'h0004, 16'h0002, 16'h0001,
                                              16'h0000 };
  
  assign x_out[0] = x_in;
  assign y_out[0] = y_in;
  assign theta_out[0] = theta_in;
  
  
  genvar j;
  generate
    
    for (j=0;j<16;j++)
      begin:stage
        cordic_stages #(.i(j),.volder_angle(theta_LUT[j])) s0
        (
          .x(x_out[j]),
          .y(y_out[j]),
          .theta(theta_out[j]),
          .x_out(x_out[j+1]),
          .y_out(y_out[j+1]),
          .theta_out(theta_out[j+1]),
          .clk(clk),
          .reset(reset),
          .mode(mode)
        );
      end
  endgenerate
  
  
  always @(posedge clk or posedge reset)
    begin
      if (reset)
        begin
          x_last <= 0;
          y_last <= 0;
          theta_last <= 0;
        end
      else
        begin
          x_last <= x_out[16];
          y_last <= y_out[16];
          theta_last <= theta_out[16];
        end
    end
 
 assign cos_theta = x_last;
 assign sin_theta = y_last;
 assign theta_final = theta_last;
  
endmodule

// Individual stages

module cordic_stages
  #(parameter i=0, volder_angle = 16'h3244)
  (
    input signed [15:0] x, y, theta,
    input clk, reset,mode,
    output signed [15:0] x_out, y_out, theta_out
  );
  
  wire signed [15:0] x_shift, y_shift;
  reg signed [15:0] x_add_out, y_add_out, theta_add_out;
  reg signed [15:0] x_reg, y_reg, theta_reg;
  wire select;
  
  assign x_shift = x_reg >>> i;
  assign y_shift = y_reg >>> i;

  assign select = mode ? ~y_reg[15] : theta_reg[15];
  
  always @(*)
    begin
      if(select)
        begin
          x_add_out = x_reg + y_shift;
          y_add_out = y_reg - x_shift;
          theta_add_out = theta_reg + volder_angle;
        end
      else
         begin
          x_add_out = x_reg - y_shift;
          y_add_out = y_reg + x_shift;
          theta_add_out = theta_reg - volder_angle;
        end
    end
  
  always @(posedge clk or posedge reset)
    begin
      if(reset)
        begin
        x_reg <= 0;
      	y_reg <= 0;
      	theta_reg <= 0;
        end
      else
        begin
        x_reg <= x;
      	y_reg <= y;
      	theta_reg <= theta;
        end
    end
    
    assign x_out = x_add_out;
    assign y_out = y_add_out;
    assign theta_out = theta_add_out;    
  
endmodule
 
