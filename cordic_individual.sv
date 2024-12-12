`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Vishnu P S 
// Create Date: 05/27/2023
// Module Name: cordic_individual
// Project Name: QR Decomposer
//
// Implements a single stage of Cordic Vectoring mode without storing theta
//////////////////////////////////////////////////////////////////////////////////


module cordic_individual
  #(parameter i=0, bit_size = 16)
  (
    input signed [bit_size-1:0] XIN, YIN,
    input clk, reset,addsub_select,
    output yreg_sign,
    output signed [bit_size-1:0] XOUT,YOUT
  );
  
  wire signed [bit_size-1:0] x_shift, y_shift;
  reg signed [bit_size-1:0] x_add_out, y_add_out;
  reg signed [bit_size-1:0] x_reg, y_reg;
    
  assign x_shift = x_reg >>> i;
  assign y_shift = y_reg >>> i;
  
  // addsub_select = 1 -> anti-clockwise rotation
  //               = 0 -> clockwise rotation 
  
  always @(*)
  begin
          if(addsub_select)
          begin
                  x_add_out = x_reg - y_shift;  
                  y_add_out = y_reg + x_shift;
          end
          else
          begin
                  x_add_out = x_reg + y_shift; 
                  y_add_out = y_reg - x_shift;
          end
  end
 
  
  always @(posedge clk or posedge reset)
  begin
      if(reset)
      begin
            x_reg <= 0;
            y_reg <= 0;
      end
      else
      begin
            x_reg <= XIN;
            y_reg <= YIN;
      end
  end
    
    assign XOUT = x_add_out;
    assign YOUT = y_add_out;  
    assign yreg_sign = y_reg[bit_size-1]; 
  
endmodule