//  Twiddle: 64-Point Twiddle Table for Radix-2^2 Butterfly
module Twiddle #(
    parameter   TW_FF = 1   //  Use Output Register
)(
    input           clock,  
    input   [5:0]   addr,   //  Twiddle Factor Number
    output  [15:0]  tw_real,  //  Twiddle Factor (Real)
    output  [15:0]  tw_complex   //  Twiddle Factor (Complex)
);

wire[15:0]  wn_real[0:63];    // Twiddle Table 
wire[15:0]  wn_complex[0:63];    
wire[15:0]  mx_real;          // Multiplexer output
wire[15:0]  mx_complex;         
reg [15:0]  ff_real;          // Register output 
reg [15:0]  ff_complex;      

assign  mx_real = wn_real[addr];
assign  mx_complex = wn_complex[addr];

always @(posedge clock) begin
    ff_real <= mx_real;
    ff_complex <= mx_complex;
end

assign  tw_real = TW_FF ? ff_real : mx_real;
assign  tw_complex = TW_FF ? ff_complex : mx_complex;

//  Twiddle Factor Value
//  Multiplication is bypassed when twiddle address is 0.
//  Setting wn_real[0] = 0 and wn_complex[0] = 0 makes it easier to check the waveform.
//  It may also reduce power consumption slightly.
//
//      wn_real = cos(-2pi*n/64)          wn_complex = sin(-2pi*n/64)
assign  wn_real[ 0] = 16'h0000;   assign  wn_complex[ 0] = 16'h0000;   //  0  1.000 -0.000
assign  wn_real[ 1] = 16'h7F62;   assign  wn_complex[ 1] = 16'hF374;   //  1  0.995 -0.098
assign  wn_real[ 2] = 16'h7D8A;   assign  wn_complex[ 2] = 16'hE707;   //  2  0.981 -0.195
assign  wn_real[ 3] = 16'h7A7D;   assign  wn_complex[ 3] = 16'hDAD8;   //  3  0.957 -0.290
assign  wn_real[ 4] = 16'h7642;   assign  wn_complex[ 4] = 16'hCF04;   //  4  0.924 -0.383
assign  wn_real[ 5] = 16'h70E3;   assign  wn_complex[ 5] = 16'hC3A9;   //  5  0.882 -0.471
assign  wn_real[ 6] = 16'h6A6E;   assign  wn_complex[ 6] = 16'hB8E3;   //  6  0.831 -0.556
assign  wn_real[ 7] = 16'h62F2;   assign  wn_complex[ 7] = 16'hAECC;   //  7  0.773 -0.634
assign  wn_real[ 8] = 16'h5A82;   assign  wn_complex[ 8] = 16'hA57E;   //  8  0.707 -0.707
assign  wn_real[ 9] = 16'h5134;   assign  wn_complex[ 9] = 16'h9D0E;   //  9  0.634 -0.773
assign  wn_real[10] = 16'h471D;   assign  wn_complex[10] = 16'h9592;   // 10  0.556 -0.831
assign  wn_real[11] = 16'h3C57;   assign  wn_complex[11] = 16'h8F1D;   // 11  0.471 -0.882
assign  wn_real[12] = 16'h30FC;   assign  wn_complex[12] = 16'h89BE;   // 12  0.383 -0.924
assign  wn_real[13] = 16'h2528;   assign  wn_complex[13] = 16'h8583;   // 13  0.290 -0.957
assign  wn_real[14] = 16'h18F9;   assign  wn_complex[14] = 16'h8276;   // 14  0.195 -0.981
assign  wn_real[15] = 16'h0C8C;   assign  wn_complex[15] = 16'h809E;   // 15  0.098 -0.995
assign  wn_real[16] = 16'h0000;   assign  wn_complex[16] = 16'h8000;   // 16  0.000 -1.000
assign  wn_real[17] = 16'hxxxx;   assign  wn_complex[17] = 16'hxxxx;   // 17 -0.098 -0.995
assign  wn_real[18] = 16'hE707;   assign  wn_complex[18] = 16'h8276;   // 18 -0.195 -0.981
assign  wn_real[19] = 16'hxxxx;   assign  wn_complex[19] = 16'hxxxx;   // 19 -0.290 -0.957
assign  wn_real[20] = 16'hCF04;   assign  wn_complex[20] = 16'h89BE;   // 20 -0.383 -0.924
assign  wn_real[21] = 16'hC3A9;   assign  wn_complex[21] = 16'h8F1D;   // 21 -0.471 -0.882
assign  wn_real[22] = 16'hB8E3;   assign  wn_complex[22] = 16'h9592;   // 22 -0.556 -0.831
assign  wn_real[23] = 16'hxxxx;   assign  wn_complex[23] = 16'hxxxx;   // 23 -0.634 -0.773
assign  wn_real[24] = 16'hA57E;   assign  wn_complex[24] = 16'hA57E;   // 24 -0.707 -0.707
assign  wn_real[25] = 16'hxxxx;   assign  wn_complex[25] = 16'hxxxx;   // 25 -0.773 -0.634
assign  wn_real[26] = 16'h9592;   assign  wn_complex[26] = 16'hB8E3;   // 26 -0.831 -0.556
assign  wn_real[27] = 16'h8F1D;   assign  wn_complex[27] = 16'hC3A9;   // 27 -0.882 -0.471
assign  wn_real[28] = 16'h89BE;   assign  wn_complex[28] = 16'hCF04;   // 28 -0.924 -0.383
assign  wn_real[29] = 16'hxxxx;   assign  wn_complex[29] = 16'hxxxx;   // 29 -0.957 -0.290
assign  wn_real[30] = 16'h8276;   assign  wn_complex[30] = 16'hE707;   // 30 -0.981 -0.195
assign  wn_real[31] = 16'hxxxx;   assign  wn_complex[31] = 16'hxxxx;   // 31 -0.995 -0.098
assign  wn_real[32] = 16'hxxxx;   assign  wn_complex[32] = 16'hxxxx;   // 32 -1.000 -0.000
assign  wn_real[33] = 16'h809E;   assign  wn_complex[33] = 16'h0C8C;   // 33 -0.995  0.098
assign  wn_real[34] = 16'hxxxx;   assign  wn_complex[34] = 16'hxxxx;   // 34 -0.981  0.195
assign  wn_real[35] = 16'hxxxx;   assign  wn_complex[35] = 16'hxxxx;   // 35 -0.957  0.290
assign  wn_real[36] = 16'h89BE;   assign  wn_complex[36] = 16'h30FC;   // 36 -0.924  0.383
assign  wn_real[37] = 16'hxxxx;   assign  wn_complex[37] = 16'hxxxx;   // 37 -0.882  0.471
assign  wn_real[38] = 16'hxxxx;   assign  wn_complex[38] = 16'hxxxx;   // 38 -0.831  0.556
assign  wn_real[39] = 16'h9D0E;   assign  wn_complex[39] = 16'h5134;   // 39 -0.773  0.634
assign  wn_real[40] = 16'hxxxx;   assign  wn_complex[40] = 16'hxxxx;   // 40 -0.707  0.707
assign  wn_real[41] = 16'hxxxx;   assign  wn_complex[41] = 16'hxxxx;   // 41 -0.634  0.773
assign  wn_real[42] = 16'hB8E3;   assign  wn_complex[42] = 16'h6A6E;   // 42 -0.556  0.831
assign  wn_real[43] = 16'hxxxx;   assign  wn_complex[43] = 16'hxxxx;   // 43 -0.471  0.882
assign  wn_real[44] = 16'hxxxx;   assign  wn_complex[44] = 16'hxxxx;   // 44 -0.383  0.924
assign  wn_real[45] = 16'hDAD8;   assign  wn_complex[45] = 16'h7A7D;   // 45 -0.290  0.957
assign  wn_real[46] = 16'hxxxx;   assign  wn_complex[46] = 16'hxxxx;   // 46 -0.195  0.981
assign  wn_real[47] = 16'hxxxx;   assign  wn_complex[47] = 16'hxxxx;   // 47 -0.098  0.995
assign  wn_real[48] = 16'hxxxx;   assign  wn_complex[48] = 16'hxxxx;   // 48 -0.000  1.000
assign  wn_real[49] = 16'hxxxx;   assign  wn_complex[49] = 16'hxxxx;   // 49  0.098  0.995
assign  wn_real[50] = 16'hxxxx;   assign  wn_complex[50] = 16'hxxxx;   // 50  0.195  0.981
assign  wn_real[51] = 16'hxxxx;   assign  wn_complex[51] = 16'hxxxx;   // 51  0.290  0.957
assign  wn_real[52] = 16'hxxxx;   assign  wn_complex[52] = 16'hxxxx;   // 52  0.383  0.924
assign  wn_real[53] = 16'hxxxx;   assign  wn_complex[53] = 16'hxxxx;   // 53  0.471  0.882
assign  wn_real[54] = 16'hxxxx;   assign  wn_complex[54] = 16'hxxxx;   // 54  0.556  0.831
assign  wn_real[55] = 16'hxxxx;   assign  wn_complex[55] = 16'hxxxx;   // 55  0.634  0.773
assign  wn_real[56] = 16'hxxxx;   assign  wn_complex[56] = 16'hxxxx;   // 56  0.707  0.707
assign  wn_real[57] = 16'hxxxx;   assign  wn_complex[57] = 16'hxxxx;   // 57  0.773  0.634
assign  wn_real[58] = 16'hxxxx;   assign  wn_complex[58] = 16'hxxxx;   // 58  0.831  0.556
assign  wn_real[59] = 16'hxxxx;   assign  wn_complex[59] = 16'hxxxx;   // 59  0.882  0.471
assign  wn_real[60] = 16'hxxxx;   assign  wn_complex[60] = 16'hxxxx;   // 60  0.924  0.383
assign  wn_real[61] = 16'hxxxx;   assign  wn_complex[61] = 16'hxxxx;   // 61  0.957  0.290
assign  wn_real[62] = 16'hxxxx;   assign  wn_complex[62] = 16'hxxxx;   // 62  0.981  0.195
assign  wn_real[63] = 16'hxxxx;   assign  wn_complex[63] = 16'hxxxx;   // 63  0.995  0.098

endmodule
