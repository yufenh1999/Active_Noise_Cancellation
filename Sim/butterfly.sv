//----------------------------------------------------------------------//
//  butterfly: Add/Sub of Two Complex Inputs							//
//----------------------------------------------------------------------//
`define WIDTH 32

module butterfly(		
	input	     signed [`WIDTH-1:0] x0_re, x0_im, 	//  Input Data #0
	input	     signed [`WIDTH-1:0] x1_re, x1_im,	//  Input Data #1
	output logic signed [`WIDTH-1:0] y0_re, y0_im, 	//  Output Data #0
	output logic signed [`WIDTH-1:0] y1_re, y1_im	//  Output Data #1
);

//===== Reg/Wire Declaration =====//
logic signed	[`WIDTH:0] add_re, add_im;		//  Input Data #0 + Input Data #1
logic signed	[`WIDTH:0] sub_re, sub_im;		//  Input Data #0 - Input Data #1

//===== Combinational =====//
//  Complex Adder
always_comb begin
	add_re = x0_re + x1_re;
	add_im = x0_im + x1_im;
	sub_re = x0_re - x1_re;
	sub_im = x0_im - x1_im;
end

always_comb begin
	y0_re = add_re[`WIDTH-1:0];
	y0_im = add_im[`WIDTH-1:0];
	y1_re = sub_re[`WIDTH-1:0];
	y1_im = sub_im[`WIDTH-1:0];
end

endmodule
