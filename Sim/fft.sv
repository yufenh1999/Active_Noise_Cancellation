`include "sdf_r22.sv"
`include "sort.sv"

`define WIDTH 32
module fft(
    input                     clk, reset,
    input                     data_in_en,
    input        [`WIDTH-1:0] data_in_re,
    input        [`WIDTH-1:0] data_in_im,
    output logic              data_out_en,
    output logic [`WIDTH-1:0] data_out_re,
    output logic [`WIDTH-1:0] data_out_im
);
logic              su1_in_en;
logic [`WIDTH-1:0] su1_in_re;
logic [`WIDTH-1:0] su1_in_im;
logic              su1_out_en;
logic [`WIDTH-1:0] su1_out_re;
logic [`WIDTH-1:0] su1_out_im;
logic              su2_out_en;
logic [`WIDTH-1:0] su2_out_re;
logic [`WIDTH-1:0] su2_out_im;
logic              su3_out_en;
logic [`WIDTH-1:0] su3_out_re;
logic [`WIDTH-1:0] su3_out_im;


// Delay constant M = 32
sdf_r22 #(.LOG_DEPTH(5)) SU1 (
    .clk(clk),
    .reset(reset),
    .data_in_en(su1_in_en),
    .data_in_re(su1_in_re),
    .data_in_im(su1_in_im),

    .data_out_en(su1_out_en),
    .data_out_re(su1_out_re),
    .data_out_im(su1_out_im)
);

// Delay constant M = 8?
sdf_r22 #(.LOG_DEPTH(3)) SU2 (
    .clk(clk),
    .reset(reset),
    .data_in_en(su1_out_en),
    .data_in_re(su1_out_re),
    .data_in_im(su1_out_im),

    .data_out_en(su2_out_en),
    .data_out_re(su2_out_re),
    .data_out_im(su2_out_im)
);

// Delay constant M = 2?
sdf_r22 #(.LOG_DEPTH(1)) SU3 (
    .clk(clk),
    .reset(reset),
    .data_in_en(su2_out_en),
    .data_in_re(su2_out_re),
    .data_in_im(su2_out_im),

    .data_out_en(su3_out_en),
    .data_out_re(su3_out_re),
    .data_out_im(su3_out_im)
);

sort st (
    .clk(clk),
    .reset(reset),
    .data_in_en(su3_out_en),
    .data_in_re(su3_out_re),
    .data_in_im(su3_out_im),

    .data_out_en(data_out_en),
    .data_out_re(data_out_re),
    .data_out_im(data_out_im)
);

always_ff @(posedge clk) begin
	if (reset) begin
		su1_in_en <= #1 0;
		su1_in_re <= #1 0;
		su1_in_im <= #1 0;
	end else begin
		su1_in_en <= #1 data_in_en;
		su1_in_re <= #1 data_in_re;
		su1_in_im <= #1 data_in_im;
	end
end

endmodule
