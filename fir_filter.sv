// FIR Filter 8 tap

module firFilter
  #(parameter WIDTH = 16, TAPS = 8, fractWidth=12)
(
  input signed [WIDTH-1:0] xn,
  input clk,reset,
  input signed [WIDTH-1:0] filterCoeff [0:TAPS-1],
  output reg signed [WIDTH-1:0] yn
);
  
  wire signed [(2*WIDTH)-1:0] mulOut [0:TAPS-1];
  wire signed [WIDTH-1:0] addOut [0:TAPS-2];
  reg signed [WIDTH-1:0] delay [0:TAPS-2];
  integer u,v;
  
  assign mulOut[0] = ($signed(filterCoeff[0]) * xn) + (2'sb01 << (fractWidth-1));
  assign addOut[0] = mulOut[0][(2*WIDTH-(WIDTH/4)-1)-:16] + mulOut[1][(2*WIDTH-(WIDTH/4)-1)-:16];
  
  genvar i;
  generate
    for (i=1;i<=TAPS-1;i=i+1)
      begin
        assign mulOut[i] = ($signed(filterCoeff[i]) * delay[i-1]) + (2'sb01 << (fractWidth-1));
      end
  endgenerate

  genvar j;
  generate
    for (j=1;j<=TAPS-2;j=j+1)
      begin
        assign addOut[j] = addOut[j-1] + mulOut[j+1][(2*WIDTH-(WIDTH/4)-1)-:16];
      end
  endgenerate
  
  genvar m;
  generate
    for (m=1;m<=TAPS-2;m=m+1)
      begin
        always @(posedge clk or posedge reset)
          begin
            if (reset)
              begin
                delay[m] <=0;
              end
            else
              begin
                delay[m] <= delay[m-1];
              end
          end
      end
  endgenerate
  
  always @(posedge clk or posedge reset)
    begin
      if (reset)
        begin
          yn <= 0;   
          delay[0] <=0;
        end
      else
        begin
          yn <= addOut[TAPS-2];     
          delay[0] <= xn;
        end
    end
  
endmodule
