`include "fft2ifft.sv"
`include "hanning_32.sv"


`define bit_length 32

module hann2ifft(
    input 		                   clk,
	input 		                   reset,
	input 		                   enable_in,
	input 	     [`bit_length-1:0] in_data,
    output logic                   enable_out,
    output logic [`bit_length-1:0] ifft_out_re, ifft_out_im
);

    logic                          fft_enable;
    logic signed [`bit_length-1:0] fft_real;
    
    hanning H2(.clk(clk), .reset(reset), .in_valid(enable_in), .in_data(in_data), .out_valid(fft_enable), .out_data(fft_real));
    fft2ifft F2(.clk(clk), .reset(reset), .enable_in(fft_enable), .fft_in_re(fft_real), .fft_in_im(32'd0), .enable_out(enable_out), .ifft_out_re(ifft_out_re), .ifft_out_im(ifft_out_im));


endmodule
