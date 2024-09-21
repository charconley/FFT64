//  Sdfu: Radix-2^2 Single-Path Delay Feedback Unit for N-Point FFT
module SdfUnit #(
    parameter   N = 64,     
    parameter   M = 64,     //  Twiddle Resolution
    parameter   WIDTH = 16  //  Data Bit Length
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

//  log2 constant function
function integer log2;
    input integer x;
    integer value;
    begin
        value = x-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end
endfunction

localparam  LOG_N = log2(N);    //  Bit Length of N
localparam  LOG_M = log2(M);    //  Bit Length of M


nternal Regs and Nets
//  1st Butterfly
reg [LOG_N-1:0] di_count;   nput Data Count
wire            bf1_bf;     //  Butterfly Add/Sub Enable
wire[WIDTH-1:0] bf1_x0_real;  //  Data #0 to Butterfly (Real)
wire[WIDTH-1:0] bf1_x0_complex;  //  Data #0 to Butterfly (Complex)
wire[WIDTH-1:0] bf1_x1_real;  //  Data #1 to Butterfly (Real)
wire[WIDTH-1:0] bf1_x1_complex;  //  Data #1 to Butterfly (Complex)
wire[WIDTH-1:0] bf1_y0_real;  //  Data #0 from Butterfly (Real)
wire[WIDTH-1:0] bf1_y0_complex;  //  Data #0 from Butterfly (Complex)
wire[WIDTH-1:0] bf1_y1_real;  //  Data #1 from Butterfly (Real)
wire[WIDTH-1:0] bf1_y1_complex;  //  Data #1 from Butterfly (Complex)
wire[WIDTH-1:0] db1_data_input_real;  //  Data to DelayBuffer (Real)
wire[WIDTH-1:0] db1_data_input_complex;  //  Data to DelayBuffer (Complex)
wire[WIDTH-1:0] db1_data_output_real;  //  Data from DelayBuffer (Real)
wire[WIDTH-1:0] db1_data_output_complex;  //  Data from DelayBuffer (Complex)
wire[WIDTH-1:0] bf1_sp_re;  //  Single-Path Data Output (Real)
wire[WIDTH-1:0] bf1_sp_im;  //  Single-Path Data Output (Complex)
reg             bf1_sp_en;  //  Single-Path Data Enable
reg [LOG_N-1:0] bf1_count;  //  Single-Path Data Count
wire            bf1_start;  //  Single-Path Output Trigger
wire            bf1_end;    //  End of Single-Path Data
wire            bf1_mj;     //  Twiddle (-j) Enable
reg [WIDTH-1:0] bf1_data_output_real;  //  1st Butterfly Output Data (Real)
reg [WIDTH-1:0] bf1_data_output_complex;  //  1st Butterfly Output Data (Complex)

//  2nd Butterfly
reg             bf2_bf;     //  Butterfly Add/Sub Enable
wire[WIDTH-1:0] bf2_x0_real;  //  Data #0 to Butterfly (Real)
wire[WIDTH-1:0] bf2_x0_complex;  //  Data #0 to Butterfly (Complex)
wire[WIDTH-1:0] bf2_x1_real;  //  Data #1 to Butterfly (Real)
wire[WIDTH-1:0] bf2_x1_complex;  //  Data #1 to Butterfly (Complex)
wire[WIDTH-1:0] bf2_y0_real;  //  Data #0 from Butterfly (Real)
wire[WIDTH-1:0] bf2_y0_complex;  //  Data #0 from Butterfly (Complex)
wire[WIDTH-1:0] bf2_y1_real;  //  Data #1 from Butterfly (Real)
wire[WIDTH-1:0] bf2_y1_complex;  //  Data #1 from Butterfly (Complex)
wire[WIDTH-1:0] db2_data_input_real;  //  Data to DelayBuffer (Real)
wire[WIDTH-1:0] db2_data_input_complex;  //  Data to DelayBuffer (Complex)
wire[WIDTH-1:0] db2_data_output_real;  //  Data from DelayBuffer (Real)
wire[WIDTH-1:0] db2_data_output_complex;  //  Data from DelayBuffer (Complex)
wire[WIDTH-1:0] bf2_sp_re;  //  Single-Path Data Output (Real)
wire[WIDTH-1:0] bf2_sp_im;  //  Single-Path Data Output (Complex)
reg             bf2_sp_en;  //  Single-Path Data Enable
reg [LOG_N-1:0] bf2_count;  //  Single-Path Data Count
reg             bf2_start;  //  Single-Path Output Trigger
wire            bf2_end;    //  End of Single-Path Data
reg [WIDTH-1:0] bf2_data_output_real;  //  2nd Butterfly Output Data (Real)
reg [WIDTH-1:0] bf2_data_output_complex;  //  2nd Butterfly Output Data (Complex)
reg             bf2_data_output_en;  //  2nd Butterfly Output Data Enable

//  Multiplication
wire[1:0]       tw_sel;     //  Twiddle Select (2n/n/3n)
wire[LOG_N-3:0] tw_num;     //  Twiddle Number (n)
wire[LOG_N-1:0] tw_addr;    //  Twiddle Table Address
wire[WIDTH-1:0] tw_real;      //  Twiddle Factor (Real)
wire[WIDTH-1:0] tw_complex;      //  Twiddle Factor (Complex)
reg             mu_en;      //  Multiplication Enable
wire[WIDTH-1:0] mu_a_real;    //  Multiplier Input (Real)
wire[WIDTH-1:0] mu_a_complex;    //  Multiplier Input (Complex)
wire[WIDTH-1:0] mu_m_real;    //  Multiplier Output (Real)
wire[WIDTH-1:0] mu_m_complex;    //  Multiplier Output (Complex)
reg [WIDTH-1:0] mu_data_output_real;   //  Multiplication Output Data (Real)
reg [WIDTH-1:0] mu_data_output_complex;   //  Multiplication Output Data (Complex)
reg             mu_data_output_en;   //  Multiplication Output Data Enable


//  1st Butterfly
always @(posedge clock or posedge reset) begin
    if (reset) begin
        di_count <= {LOG_N{1'b0}};
    end else begin
        di_count <= data_input_en ? (di_count + 1'b1) : {LOG_N{1'b0}};
    end
end
assign  bf1_bf = di_count[LOG_M-1];

//  Set unknown value x for verification
assign  bf1_x0_real = bf1_bf ? db1_data_output_real : {WIDTH{1'bx}};
assign  bf1_x0_complex = bf1_bf ? db1_data_output_complex : {WIDTH{1'bx}};
assign  bf1_x1_real = bf1_bf ? data_input_real : {WIDTH{1'bx}};
assign  bf1_x1_complex = bf1_bf ? data_input_complex : {WIDTH{1'bx}};

Butterfly #(.WIDTH(WIDTH),.RH(0)) BF1 (
    .x0_real  (bf1_x0_real  ),  
    .x0_complex  (bf1_x0_complex  ), 
    .x1_real  (bf1_x1_real  ),  
    .x1_complex  (bf1_x1_complex  ), 
    .y0_real  (bf1_y0_real  ),  
    .y0_complex  (bf1_y0_complex  ), 
    .y1_real  (bf1_y1_real  ),  
    .y1_complex  (bf1_y1_complex  ) 
);

DelayBuffer #(.DEPTH(2**(LOG_M-1)),.WIDTH(WIDTH)) DB1 (
    .clock  (clock      ),  
    .data_input_real  (db1_data_input_real  ),  
    .data_input_complex  (db1_data_input_complex  ),  
    .data_output_real  (db1_data_output_real  ),  
    .data_output_complex  (db1_data_output_complex  )   
);

assign  db1_data_input_real = bf1_bf ? bf1_y1_real : data_input_real;
assign  db1_data_input_complex = bf1_bf ? bf1_y1_complex : data_input_complex;
assign  bf1_sp_re = bf1_bf ? bf1_y0_real : bf1_mj ?  db1_data_output_complex : db1_data_output_real;
assign  bf1_sp_im = bf1_bf ? bf1_y0_complex : bf1_mj ? -db1_data_output_real : db1_data_output_complex;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf1_sp_en <= 1'b0;
        bf1_count <= {LOG_N{1'b0}};
    end else begin
        bf1_sp_en <= bf1_start ? 1'b1 : bf1_end ? 1'b0 : bf1_sp_en;
        bf1_count <= bf1_sp_en ? (bf1_count + 1'b1) : {LOG_N{1'b0}};
    end
end
assign  bf1_start = (di_count == (2**(LOG_M-1)-1));
assign  bf1_end = (bf1_count == (2**LOG_N-1));
assign  bf1_mj = (bf1_count[LOG_M-1:LOG_M-2] == 2'd3);

always @(posedge clock) begin
    bf1_data_output_real <= bf1_sp_re;
    bf1_data_output_complex <= bf1_sp_im;
end

//  2nd Butterfly
always @(posedge clock) begin
    bf2_bf <= bf1_count[LOG_M-2];
end

//  Set unknown value x for verification
assign  bf2_x0_real = bf2_bf ? db2_data_output_real : {WIDTH{1'bx}};
assign  bf2_x0_complex = bf2_bf ? db2_data_output_complex : {WIDTH{1'bx}};
assign  bf2_x1_real = bf2_bf ? bf1_data_output_real : {WIDTH{1'bx}};
assign  bf2_x1_complex = bf2_bf ? bf1_data_output_complex : {WIDTH{1'bx}};

//  Negative bias occurs when RH=0 and positive bias occurs when RH=1.
//  Using both alternately reduces the overall rounding error.
Butterfly #(.WIDTH(WIDTH),.RH(1)) BF2 (
    .x0_real        (bf2_x0_real  ),  
    .x0_complex  (bf2_x0_complex  ),  
    .x1_real        (bf2_x1_real  ),  
    .x1_complex  (bf2_x1_complex  ),  
    .y0_real        (bf2_y0_real  ),  
    .y0_complex  (bf2_y0_complex  ),  
    .y1_real        (bf2_y1_real  ),  
    .y1_complex  (bf2_y1_complex  )   
);

DelayBuffer #(.DEPTH(2**(LOG_M-2)),.WIDTH(WIDTH)) DB2 (
    .clock                            (clock      ),  
    .data_input_real        (db2_data_input_real  ),  
    .data_input_complex  (db2_data_input_complex  ),  
    .data_output_real      (db2_data_output_real  ),  
    .data_output_complex (db2_data_output_complex  )   
);

assign  db2_data_input_real = bf2_bf ? bf2_y1_real : bf1_data_output_real;
assign  db2_data_input_complex = bf2_bf ? bf2_y1_complex : bf1_data_output_complex;
assign  bf2_sp_re = bf2_bf ? bf2_y0_real : db2_data_output_real;
assign  bf2_sp_im = bf2_bf ? bf2_y0_complex : db2_data_output_complex;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf2_sp_en <= 1'b0;
        bf2_count <= {LOG_N{1'b0}};
    end else begin
        bf2_sp_en <= bf2_start ? 1'b1 : bf2_end ? 1'b0 : bf2_sp_en;
        bf2_count <= bf2_sp_en ? (bf2_count + 1'b1) : {LOG_N{1'b0}};
    end
end

always @(posedge clock) begin
    bf2_start <= (bf1_count == (2**(LOG_M-2)-1)) & bf1_sp_en;
end
assign  bf2_end = (bf2_count == (2**LOG_N-1));

always @(posedge clock) begin
    bf2_data_output_real <= bf2_sp_re;
    bf2_data_output_complex <= bf2_sp_im;
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        bf2_data_output_en <= 1'b0;
    end else begin
        bf2_data_output_en <= bf2_sp_en;
    end
end

//  Multiplication
assign  tw_sel[1] = bf2_count[LOG_M-2];
assign  tw_sel[0] = bf2_count[LOG_M-1];
assign  tw_num = bf2_count << (LOG_N-LOG_M);
assign  tw_addr = tw_num * tw_sel;

Twiddle TW (
    .clock  (clock  ),  
    .addr   (tw_addr),  
    .tw_real  (tw_real  ),  
    .tw_complex  (tw_complex  )   
);

//  Multiplication is bypassed when twiddle address is 0.
always @(posedge clock) begin
    mu_en <= (tw_addr != {LOG_N{1'b0}});
end
//  Set unknown value x for verification
assign  mu_a_real = mu_en ? bf2_data_output_real : {WIDTH{1'bx}};
assign  mu_a_complex = mu_en ? bf2_data_output_complex : {WIDTH{1'bx}};

Multiply #(.WIDTH(WIDTH)) MU (
    .a_real         (mu_a_real),  
    .a_complex   (mu_a_complex),  
    .b_real         (tw_real  ),  
    .b_complex   (tw_complex  ),  
    .m_real         (mu_m_real),  
    .m_complex   (mu_m_complex)   
);

always @(posedge clock) begin
    mu_data_output_real <= mu_en ? mu_m_real : bf2_data_output_real;
    mu_data_output_complex <= mu_en ? mu_m_complex : bf2_data_output_complex;
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        mu_data_output_en <= 1'b0;
    end else begin
        mu_data_output_en <= bf2_data_output_en;
    end
end

//  No multiplication required at final stage
assign  data_output_en = (LOG_M == 2) ? bf2_data_output_en : mu_data_output_en;
assign  data_output_real = (LOG_M == 2) ? bf2_data_output_real : mu_data_output_real;
assign  data_output_complex = (LOG_M == 2) ? bf2_data_output_complex : mu_data_output_complex;

endmodule
