//  Butterfly: Add/Sub and Scaling
module Butterfly #(
    parameter   WIDTH = 16,
    parameter   RH = 0  //  Round Half Up
)(
    input   signed  [WIDTH-1:0] x0_real, 
    input   signed  [WIDTH-1:0] x0_complex, 
    input   signed  [WIDTH-1:0] x1_real,  
    input   signed  [WIDTH-1:0] x1_complex, 
    output  signed  [WIDTH-1:0] y0_real, 
    output  signed  [WIDTH-1:0] y0_complex,  
    output  signed  [WIDTH-1:0] y1_real, 
    output  signed  [WIDTH-1:0] y1_complex  
);

wire signed [WIDTH:0]   add_re, add_im, sub_re, sub_im;

//  Add/Sub
assign  add_re = x0_real + x1_real;
assign  add_im = x0_complex + x1_complex;
assign  sub_re = x0_real - x1_real;
assign  sub_im = x0_complex - x1_complex;

//  Scaling
assign  y0_real = (add_re + RH) >>> 1;
assign  y0_complex = (add_im + RH) >>> 1;
assign  y1_real = (sub_re + RH) >>> 1;
assign  y1_complex = (sub_im + RH) >>> 1;

endmodule
