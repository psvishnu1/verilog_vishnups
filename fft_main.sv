/* FFT & IFFT Selector

    If Mode = 0 -> Performs Forward FFT & if Mode = 1 -> Performs IFFT
    
    Steps for doing IFFT using Forward FFT Module are as follows:
        1) Swap Real & Imaginary parts in the input
        2) Perform forward FFT
        3) Again swap Real & Imaginary at the output side
        4) Scale the output by number of inputs
        
*/

module fft_main
#(parameter twdl1 = 16'sh0b50, twdl2 = 16'shf4b0, fractWidth = 15)
(
  input signed [15:0] xn [0:7][0:1],
  input clk,reset,mode,
  output reg signed [15:0] yn [0:7][0:1]
);

reg signed [15:0] main_input [0:7][0:1];
wire signed [15:0] main_output [0:7][0:1];

integer i,j,u,v,m,n;

always @(negedge clk)
  begin
  
    if (reset)
        begin
        for (m=0;m<8;m=m+1)
            begin
                main_input[m][0] <= 0;
                main_input[m][1] <= 0;
            end
        end
        
    else
        begin
            if (~mode)
            begin
                for (i=0;i<8;i=i+1)
                    begin
                        main_input[i][0] <= xn[i][0];
                        main_input[i][1] <= xn[i][1];
                    end
            end
            else
            begin
                for (j=0;j<8;j=j+1)
                    begin
                        main_input[j][0] <= xn[j][1];
                        main_input[j][1] <= xn[j][0];
                    end
            end
        end
  end

fwd_fft #(.fractWidth(fractWidth),.twdl1(twdl1),.twdl2(twdl2)) fft2
(
   .xn(main_input),
   .yn(main_output),
   .clk(clk),
   .reset(reset)
 );
           
always @(posedge clk)
  begin
  
    if (reset)
        begin
        for (n=0;n<8;n=n+1)
        begin
            yn[n][0] <= 0;
            yn[n][1] <= 0;
        end
        end
        
    else
    begin
        if (~mode)
            begin
                for (u=0;u<8;u=u+1)
                    begin
                        yn[u][0] <= main_output[u][0];
                        yn[u][1] <= main_output[u][1];
                    end
            end
        else
            begin
                for (v=0;v<8;v=v+1)
                    begin
                        yn[v][0] <= main_output[v][1]/8;
                        yn[v][1] <= main_output[v][0]/8;
                    end
            end
     end  
  end
endmodule