
module decim_top (
    input  wire               clk,
    input  wire               reset,        
    input  wire               enable,
    input  wire signed [1:0]  bits,
    output reg  signed [19:0] firout,
    output reg                fir_ready  
);

    localparam signed [21:0] H0 =  22'sd17492;     //  0.2669
    localparam signed [21:0] H1 = -22'sd47114;     // -0.7189
    localparam signed [21:0] H2 =  22'sd124781;    //  1.9040

 
    reg signed [34:0] i1, i2, i3;            
    reg signed [34:0] d1, d2, d3;            
    reg        [10:0] cnt;
    reg signed [34:0] c1, c2, c3;
  
    reg signed [34:0] mid;                    
    reg signed [34:0] p1, p2, p3, p4;         
    reg signed [63:0] y, r;               

    always @(posedge clk) begin
        if (reset) begin
            i1 <= 0; i2 <= 0; i3 <= 0;  d1 <= 0; d2 <= 0; d3 <= 0;
            cnt <= 0;
            p1 <= 0; p2 <= 0; p3 <= 0; p4 <= 0;
            firout <= 0; fir_ready <= 0;
        end else if (enable) begin
            i1 <= i1 + bits;
            i2 <= i2 + i1;
            i3 <= i3 + i2;
            cnt <= cnt + 1;
            fir_ready <= 0;

            if (cnt == 11'd2047) begin        
                c1 = i3 - d1;   d1 <= i3;
                c2 = c1 - d2;   d2 <= c1;
                c3 = c2 - d3;   d3 <= c2;
                  
                 mid = c3;
                y = H0*(mid + p4) + H1*(p1 + p3) + H2*p2;
                p4 <= p3;  p3 <= p2;  p2 <= p1;  p1 <= mid;
                
                r = (y + 64'sd536870912) >>>30; // divide by 2^30 , 2^16 for coefficients and 2^14 to make 20 bits
                if      (r >  64'sd524287) firout <= 20'sd524287;    // cliping if exceeds 20bits
                else if (r < -64'sd524288) firout <= -20'sd524288;
                else                       firout <= r[19:0];
                fir_ready <= 1;
            end
        end
    end
endmodule
