//	TB: FftTop Testbench
`timescale	1ns/1ns
module TB;

reg 		clock;
reg 		reset;
reg 		data_input_en;
reg [15:0]	data_input_real;
reg [15:0]	data_input_complex;
wire		data_output_en;
wire[15:0]	data_output_real;
wire[15:0]	data_output_complex;

reg [15:0]	imem[0:127];
reg [15:0]	omem[0:127];

//	Clock and Reset
always begin
	clock = 0; #10;
	clock = 1; #10;
end

initial begin
	reset = 0; #20;
	reset = 1; #100;
	reset = 0;
end

//	Functional Blocks

//	Input Control Initialize
initial begin
	wait (reset == 1);
	data_input_en = 0;
end

//	Output Data Capture
initial begin : OCAP
	integer 	n;
	forever begin
		n = 0;
		while (data_output_en !== 1) @(negedge clock);
		while ((data_output_en == 1) && (n < 64)) begin
			omem[2*n  ] = data_output_real;
			omem[2*n+1] = data_output_complex;
			n = n + 1;
			@(negedge clock);
		end
	end
end

//	Tasks
task LoadInputData;
	input[80*8:1]	filename;
begin
	$readmemh(filename, imem);
end
endtask

task GenerateInputWave;
	integer n;
begin
	data_input_en <= 1;
	for (n = 0; n < 64; n = n + 1) begin
		data_input_real <= imem[2*n];
		data_input_complex <= imem[2*n+1];
		@(posedge clock);
	end
	data_input_en <= 0;
	data_input_real <= 'bx;
	data_input_complex <= 'bx;
end
endtask

task SaveOutputData;
	input[80*8:1]	filename;
	integer 		fp, n, m;
begin
	fp = $fopen(filename);
	m = 0;
	for (n = 0; n < 64; n = n + 1) begin
		m[5] = n[0];
		m[4] = n[1];
		m[3] = n[2];
		m[2] = n[3];
		m[1] = n[4];
		m[0] = n[5];
		$fdisplay(fp, "%h  %h  // %d", omem[2*m], omem[2*m+1], n[5:0]);
	end
	$fclose(fp);
end
endtask

//	Module Instances
FFT FFT (
	.clock	(clock								),
	.reset	(reset								),	
	.data_input_en	(data_input_en				),	
	.data_input_real (data_input_real			),	
	.data_input_complex	(data_input_complex		),	
	.data_output_en	(data_output_en				),	
	.data_output_real	(data_output_real		),	
	.data_output_complex (data_output_complex	)	
);

`include "stim.v"

endmodule
