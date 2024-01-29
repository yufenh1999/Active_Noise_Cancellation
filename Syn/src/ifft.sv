`define WIDTH 32
module ifft(
    input                     clk, reset,
    input                     data_in_en,
    input        [`WIDTH-1:0] data_in_re,    // (32, 24)
    input        [`WIDTH-1:0] data_in_im,    // (32, 24)
    output logic              data_out_en,
    output logic [`WIDTH-1:0] data_out_re,   // (32, 24)
    output logic [`WIDTH-1:0] data_out_im    // (32, 24)
);
logic signed [`WIDTH-1:0] e_data_in_re, e_data_in_im;
logic signed [`WIDTH-1:0] ifft_re, ifft_im;
logic 			          ifft_out_en;
logic signed [`WIDTH-1:0] n_data_out_re, n_data_out_im;
logic 			          n_data_out_en;

assign e_data_in_re = data_in_en?  data_in_re : 'b0;
assign e_data_in_im = data_in_en? -data_in_im : 'b0;
assign n_data_out_en = ifft_out_en;
assign n_data_out_re = ifft_re >>> 6;
assign n_data_out_im = ifft_im >>> 6;

fft fft64 (
    .clk(clk),
    .reset(reset),
    .data_in_en(data_in_en),
    .data_in_re(e_data_in_re),    // (32, 24)
    .data_in_im(e_data_in_im),    // (32, 24)
    .data_out_en(ifft_out_en),
    .data_out_re(ifft_re),  // (32, 24)
    .data_out_im(ifft_im)   // (32, 24)
);


always_ff @(posedge clk) begin
	if (reset) begin
		data_out_en <= 1'b0;
		data_out_re <= 'b0;
		data_out_im <= 'b0;
	end else begin
		data_out_en <= n_data_out_en;
		data_out_re <= n_data_out_re;
		data_out_im <= n_data_out_im;
	end
end

endmodule
