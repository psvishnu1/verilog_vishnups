`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Palakkad
// Engineer: Vishnu P S 
//////////////////////////////////////////////////////////////////////////////////

module tc_top
(
    input clk,reset,
    output Hr,Hg,Cr,Cg,Hb,Cb,
    output [7:0] decoder_out,
    output [7:0] led_anode 
);

wire new_clk, pwm_out, state;
wire [2:0] timer_in;
wire [2:0] count_c, count_h;

assign timer_in = state ? count_h : count_c;

assign led_anode = 8'b11111110;

traffic_light_controller tc1 (.clk(new_clk),.reset(reset),.Hr(Hr),.Hg(Hg),.Cr(Cr),.Cg(Cg), .count_h(count_h), .count_c(count_c),.pwm_in(pwm_out), .Hb(Hb), .Cb(Cb), .status(state));
clock_divider c1 (.clkin(clk), .reset(reset), .clkout(new_clk));
bcd_to_7seg_decoder decod1 (.Ain(timer_in), .Aout(decoder_out));
pwm p1 (.clk(clk), .reset(reset), .pwm_out(pwm_out)); 

endmodule


module traffic_light_controller
(
    input clk,reset,pwm_in,
    output reg Hr,Hg,Hb,Cr,Cg,Cb,
    output [2:0] count_h, count_c,
    output reg status
);

parameter Highway_green = 0;
parameter Crossroad_green = 1;

reg state, next_state;
wire count_over_h, count_over_c;
wire h_counter_reset, c_counter_reset;

counter #(.max_count(3'd7)) h_counter(.clk(clk), .reset(h_counter_reset), .count(count_h), .count_over(count_over_h));
counter #(.max_count(3'd3)) c_counter(.clk(clk), .reset(c_counter_reset), .count(count_c), .count_over(count_over_c));

assign c_counter_reset = reset || (state == Highway_green);
assign h_counter_reset = reset || (state == Crossroad_green);

always @(posedge clk or posedge reset)
begin
    if (reset)
        state <= Highway_green;
    else
        state <= next_state;
end

//always @(*)
//begin
//    case (state)
//        Highway_green:
//        begin
//            Hg = 1;
//            Hr = ~Hg;
//            Cr = Hg;
//            Cg = Hr;
//            next_state = count_over_h ? Crossroad_green : Highway_green;
//        end
//        Crossroad_green:
//        begin
//            Hg = 0;
//            Hr = ~Hg;
//            Cr = Hg;
//            Cg = Hr;
//            next_state = count_over_c ? Highway_green : Crossroad_green;
//        end
//    endcase
//end

always @(*)
begin
    case (state)
        Highway_green:
        begin
            status = 1;
            Hg = pwm_in;
            Hr = 0;
            Cr = pwm_in;
            Cg = 0;
            Hb = 0;
            Cb = 0;
            next_state = count_over_h ? Crossroad_green : Highway_green;
        end
        Crossroad_green:
        begin
            status = 0;
            Hg = 0;
            Hr = pwm_in;
            Cr = 0;
            Cg = pwm_in;
            Hb = 0;
            Cb = 0;
            next_state = count_over_c ? Highway_green : Crossroad_green;
        end
    endcase
end

endmodule

module clock_divider
(
    input clkin,reset,
    output reg clkout
);

reg clkmux;
reg [25:0] count;
wire count_over;

//assign count_over = count==26'd62500000;
assign count_over = count==26'd50000000;

always @(posedge clkin or posedge reset)
begin
    if (reset || count_over)
        count <= 0;
    else
        count = count + 1;
end

always @(posedge clkin or posedge reset)
begin
    if (reset)
        clkout <= 1;
    else
        clkout <= clkmux;
end

always @(*)
begin
    if (count_over)
        clkmux = ~clkout;
    else
        clkmux = clkout;
end

endmodule

module bcd_to_7seg_decoder
(
    input [2:0] Ain,
    output reg [7:0] Aout
);



//always @(*)
//begin
//    case (Ain)
//        3'd0: Aout = 7'b1111110;
//        3'd1: Aout = 7'b0110000;
//        3'd2: Aout = 7'b1101101;
//        3'd3: Aout = 7'b1111001;
//        3'd4: Aout = 7'b0110011;
//        3'd5: Aout = 7'b1011011;
//        3'd6: Aout = 7'b1011111;
//        3'd7: Aout = 7'b1110000;
//        default: Aout = 7'b0000001;
//    endcase
//end

always @(*)
begin
    case (Ain)
        3'd0: Aout = 8'b00000011;
        3'd1: Aout = 8'b10011111;
        3'd2: Aout = 8'b00100101;
        3'd3: Aout = 8'b00001101;
        3'd4: Aout = 8'b10011001;
        3'd5: Aout = 8'b01001001;
        3'd6: Aout = 8'b01000001;
        3'd7: Aout = 8'b00011111;
        default: Aout = 8'b00000011;
    endcase
end

endmodule

`timescale 1ns / 1ps
 
module pwm
(
    input clk,reset,
    output pwm_out
);  
   
localparam total_time = 7;   
localparam on_time = 1;
    
reg [3:0] counter;

always @(posedge clk or posedge reset)
begin
    if (reset || (counter==total_time))
        counter <= 0;
    else
        counter<=counter+1'b1;
end    
 
assign pwm_out=(counter<on_time) ? 1:0;
    
endmodule

module counter
#(parameter max_count = 3'd7)
(
    input clk, reset,
    output count_over, 
    output reg [2:0] count
);

assign count_over = (count == 3'd0);

always @(posedge clk or posedge reset)
begin
    if (reset)
        count <= max_count;
    else
        count <= count - 1'b1;
end
        
endmodule

