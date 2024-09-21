//  FFT: 64-Point FFT Using Radix-2^2 Single-Path Delay Feedback
module FFT #(
    parameter   WIDTH = 16
)(
    input               clock,  
    input               reset,  
    input               data_input_en, 
    input   [WIDTH-1:0] data_input_real,  
    input   [WIDTH-1:0] data_input_complex,  
    output              data_output_en,  
    output  [WIDTH-1:0] data_output_real,  
    output  [WIDTH-1:0] data_output_complex 
);
  
//  The result is scaled to 1/N and output in bit-reversed order.
//  The output latency is 71 clock cycles.

wire            su1_do_en;
wire[WIDTH-1:0] su1_do_re;
wire[WIDTH-1:0] su1_do_im;
wire            su2_do_en;
wire[WIDTH-1:0] su2_do_re;
wire[WIDTH-1:0] su2_do_im;

SdfUnit #(.N(64),.M(64),.WIDTH(WIDTH)) SU1 (
    .clock  (clock      ),  //  i
    .reset  (reset      ),  //  i
    .data_input_en  (data_input_en),  //  i
    .data_input_real  (data_input_real      ),  //  i
    .data_input_complex  (data_input_complex      ),  //  i
    .data_output_en  (su1_do_en  ),  //  o
    .data_output_real  (su1_do_re  ),  //  o
    .data_output_complex  (su1_do_im  )   //  o
);

SdfUnit #(.N(64),.M(16),.WIDTH(WIDTH)) SU2 (
    .clock  (clock      ),  //  i
    .reset  (reset      ),  //  i
    .data_input_en  (su1_do_en  ),  //  i
    .data_input_real  (su1_do_re  ),  //  i
    .data_input_complex  (su1_do_im  ),  //  i
    .data_output_en  (su2_do_en  ),  //  o
    .data_output_real  (su2_do_re  ),  //  o
    .data_output_complex  (su2_do_im  )   //  o
);

SdfUnit #(.N(64),.M(4),.WIDTH(WIDTH)) SU3 (
    .clock  (clock      ),  //  i
    .reset  (reset      ),  //  i
    .data_input_en  (su2_do_en  ),  //  i
    .data_input_real  (su2_do_re  ),  //  i
    .data_input_complex  (su2_do_im  ),  //  i
    .data_output_en  (data_output_en      ),  //  o
    .data_output_real  (data_output_real      ),  //  o
    .data_output_complex  (data_output_complex      )   //  o
);

endmodule
