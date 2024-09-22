# FFT

I designed this 64-point FFT Verilog implementation as a class project in order to learn more about Verilog, as well as the Fourier Transform and its applications.
I implemented a Radix-2^2 SDF (single-path delay feedback) architecture with scaled, (where N is a power of 4), fix point arithmetic. The result is scaled to 1/N and output in bit reversed order (Output4.txt and output5.txt). Output latentcy is 71 clock cycles. I utilized Vivado to synthesize and verify the program. A number of references were used for this project, most notably: [HAL](https://hal.science/hal-01800743/document) and [Reasearch Gate](https://www.researchgate.net/figure/N-point-R22SDF-pipeline-FFT-processor-architecture_fig2_26850326)
