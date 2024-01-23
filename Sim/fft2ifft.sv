`include "top.sv"
`include "fft.sv"
`include "ifft.sv"

`define bit_length 32

module fft2ifft(
    input                          clk,reset,
    input                          enable_in,
    input        [`bit_length-1:0] fft_in_re, fft_in_im,
    output logic                   enable_out,
    output logic [`bit_length-1:0] ifft_out_re, ifft_out_im
    );

logic                          top_enable;
logic signed [`bit_length-1:0] top_real, top_imag;
logic                          ifft_enable;
logic signed [`bit_length-1:0] ifft_real, ifft_imag;

fft F1(.clk(clk), .reset(reset), .data_in_en(enable_in), .data_in_re(fft_in_re), .data_in_im(fft_in_im), .data_out_en(top_enable), .data_out_re(top_real), .data_out_im(top_imag));
top T1(.clk(clk), .reset(reset), .enable_in(top_enable), .x_re(top_real), .x_im(top_imag), .enable_out(ifft_enable), .x_re_out(ifft_real), .x_im_out(ifft_imag));
ifft I1(.clk(clk), .reset(reset), .data_in_en(ifft_enable), .data_in_re(ifft_real), .data_in_im(ifft_imag), .data_out_en(enable_out), .data_out_re(ifft_out_re), .data_out_im(ifft_out_im));

endmodule
