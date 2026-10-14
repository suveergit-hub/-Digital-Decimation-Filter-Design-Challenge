
module cic_top (
    input  wire               clk,
    input  wire               reset,          
    input  wire               enable,
    input  wire signed [1:0]  bits,          
    output reg  signed [19:0] cicout,
    output reg                outready
);
    reg signed [34:0] i1, i2, i3;             
    reg signed [34:0] d1, d2, d3;            
    reg        [10:0] cnt;                  
    reg signed [34:0] c1, c2, c3, r;

    always @(posedge clk) begin
        if (reset) begin
            i1 <= 0; i2 <= 0; i3 <= 0;
            d1 <= 0; d2 <= 0; d3 <= 0;
            cnt <= 0; cicout <= 0; outready <= 0;
        end else if (enable) begin
            i1 <= i1 + bits;
            i2 <= i2 + i1;
            i3 <= i3 + i2;

            cnt      <= cnt + 1;           
            outready <= 0;

            if (cnt == 11'd2047) begin
                c1 = i3 - d1;   d1 <= i3;
                c2 = c1 - d2;   d2 <= c1;
                c3 = c2 - d3;   d3 <= c2;

                r = (c3 + 35'sd8192) >>> 14;  // rounding up before dividing
                if      (r >  35'sd524287) cicout <= 20'sd524287;    // cliping if exceeds 20bits
                else if (r < -35'sd524288) cicout <= -20'sd524288;
                else                       cicout <= r[19:0];
                outready <= 1;
            end
        end
    end
endmodule
