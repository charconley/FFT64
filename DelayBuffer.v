//  DelayBuffer: Generate Constant Delay
module DelayBuffer #(
    parameter   DEPTH = 32,
    parameter   WIDTH = 16
)(
    input               clock,  //  Master Clock
    input   [WIDTH-1:0] data_input_real,  //  Data Input (Real)
    input   [WIDTH-1:0] data_input_complex,  //  Data Input (Imag)
    output  [WIDTH-1:0] data_output_real,  //  Data Output (Real)
    output  [WIDTH-1:0] data_output_complex   //  Data Output (Imag)
);

reg [WIDTH-1:0] buf_re[0:DEPTH-1];
reg [WIDTH-1:0] buf_im[0:DEPTH-1];
integer n;

//  Shift Buffer
always @(posedge clock) begin
    for (n = DEPTH-1; n > 0; n = n - 1) begin
        buf_re[n] <= buf_re[n-1];
        buf_im[n] <= buf_im[n-1];
    end
    buf_re[0] <= data_input_real;
    buf_im[0] <= data_input_complex;
end

assign  data_output_real = buf_re[DEPTH-1];
assign  data_output_complex = buf_im[DEPTH-1];

endmodule
