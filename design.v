// Experiment 3

//Top module
module square_accr_top(
  input [3:0] N,
  input clk,reset,N_valid,
  output [7:0] sum,
  output sum_valid
);
  
  wire j_eq_i, i_eq_0, i_mux_sel,acc_mux_sel,i_en,j_mux_sel;
  
  datapath d1(.N(N),
              .clk(clk),
              .i_mux_sel(i_mux_sel),
              .j_mux_sel(j_mux_sel),
              .acc_mux_sel(acc_mux_sel),
              .i_en(i_en),
              .sum(sum),
              .i_eq_0(i_eq_0),
              .j_eq_i(j_eq_i));
  
  controlpath c1(.N_valid(N_valid),
                 .clk(clk),
                 .reset(reset),
                 .i_eq_0(i_eq_0),
                 .j_eq_i(j_eq_i),
                 .sum_valid(sum_valid),
                 .i_mux_sel(i_mux_sel),
                 .j_mux_sel(j_mux_sel),
                 .acc_mux_sel(acc_mux_sel),
                 .i_en(i_en));
  
endmodule

// Data path
module datapath(
  input [3:0] N,
  input clk, i_mux_sel, acc_mux_sel,i_en,j_mux_sel,
  output [7:0] sum,
  output i_eq_0, j_eq_i
);
  
  wire [7:0] add_out, acc_mux_out;
  wire [3:0] i_mux_out, j_mux_out;

  reg [3:0] i,j;
  reg [7:0] i_acc;
  
  assign i_mux_out = i_mux_sel ? i - 1 : N;
  assign acc_mux_out = acc_mux_sel ? add_out : 0;
  assign j_mux_out = j_mux_sel ? j + 1 : 1;
  assign i_eq_0 = ( i == 4'b0000 );
  assign j_eq_i = ( j == i );
  assign add_out = i + i_acc;
  
  always @(posedge clk)
    begin
      i_acc <= acc_mux_out;
      j <= j_mux_out;
      
      if (i_en)
        i <= i_mux_out;
      
    end
  
  assign sum = i_eq_0 ? i_acc : 0;
  
endmodule

// Control path
module controlpath(
  input N_valid,clk,reset,i_eq_0,j_eq_i,
  output reg sum_valid,i_mux_sel,acc_mux_sel,i_en,j_mux_sel
);
  
  parameter idle = 2'b00;
  parameter accumulation = 2'b01;
  parameter done = 2'b10;
  
  reg [1:0] state = 2'b00;
  reg [1:0] nextstate;
  
  always @(*)
    begin
      case (state)
        idle:
          if (N_valid)
            nextstate = accumulation; 
        
        accumulation:
          if (i_eq_0)
            nextstate = done;
        
        done:
          nextstate = idle;
        
        default:
          nextstate = idle;
       endcase
    end
        
  always @(*)
    begin
      case (state)
 
          idle:
            begin   
              acc_mux_sel = 0;
              j_mux_sel = 0;
              i_en = 1;            
              if (N_valid)
              begin
                i_mux_sel = 0;
              end
            end

          accumulation:
            begin
              i_en = 0;
              j_mux_sel = 1;
              acc_mux_sel = 1;
              if (j_eq_i)
                begin
                i_en = 1;
                i_mux_sel = 1;
                j_mux_sel = 0;
                end      
            end
      endcase
    end
  
  always @(posedge clk or posedge reset)
    begin
      if (reset)
        state <= idle;
      else
        state <= nextstate;
    end
  
  assign sum_valid = (state == done);
  
endmodule

          
