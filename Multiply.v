//  Multiply: Complex Multiplier
module Multiply #(
    parameter   WIDTH = 16
)(
    input   signed  [WIDTH-1:0] a_real,
    input   signed  [WIDTH-1:0] a_complex,
    input   signed  [WIDTH-1:0] b_real,
    input   signed  [WIDTH-1:0] b_complex,
    output  signed  [WIDTH-1:0] m_real,
    output  signed  [WIDTH-1:0] m_complex
);

wire signed [WIDTH*2-1:0]   arbr, arbi, aibr, aibi; //a_real*b_real, for example
wire signed [WIDTH-1:0]     sc_arbr, sc_arbi, sc_aibr, sc_aibi;

//  Signed Multiplication
assign  arbr = a_real * b_real;
assign  arbi = a_real * b_complex;
assign  aibr = a_complex * b_real;
assign  aibi = a_complex * b_complex;

//  Scaling
assign  sc_arbr = arbr >>> (WIDTH-1);
assign  sc_arbi = arbi >>> (WIDTH-1);
assign  sc_aibr = aibr >>> (WIDTH-1);
assign  sc_aibi = aibi >>> (WIDTH-1);

//  Sub/Add
//  These sub/add may overflow if unnormalized data is input.
assign  m_real = sc_arbr - sc_aibi;
assign  m_complex = sc_arbi + sc_aibr;

endmodule
