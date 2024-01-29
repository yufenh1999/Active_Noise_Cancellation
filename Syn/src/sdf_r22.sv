//----------------------------------------------------------------------//
//  sdf_r22: radix-2^2 single-path delay feedback for 64-point FFT		//
//----------------------------------------------------------------------//
`include "butterfly.sv"
`include "delay_buffer.sv"
`include "twiddle.sv"
`define WIDTH 32
`define LOG_N 6

module sdf_r22 #(
	parameter	LOG_DEPTH = 5     //  Delay Buffer Depth = 32
)(
	input					  		 clk, reset,
	input         		      		 data_in_en,				//  Data Input Enable
	input		 signed [`WIDTH-1:0] data_in_re,  data_in_im,	//  Data Input
	output        		      		 data_out_en,				//  Data Output Enable
	output logic signed [`WIDTH-1:0] data_out_re, data_out_im	//  Data Output
);

//--------------------------------------------------------------//
//  1st radix-2 Single-Path Delay Feedback						//	
//--------------------------------------------------------------//
//===== Reg/Wire Declaration =====//
logic        [`LOG_N-1:0] data_in_cnt;							//  Input Data Count
logic            		  bf1_in_en;							//  Butterfly Input Enable
logic signed [`WIDTH-1:0] bf1_x0_re, bf1_x0_im;					//  Input Data #0 to butterfly
logic signed [`WIDTH-1:0] bf1_x1_re, bf1_x1_im;					//  Input Data #1 to butterfly
logic signed [`WIDTH-1:0] bf1_y0_re, bf1_y0_im;					//  Output Data #0 from butterfly
logic signed [`WIDTH-1:0] bf1_y1_re, bf1_y1_im;					//  Output Data #1 from butterfly

logic signed [`WIDTH-1:0] db1_data_in_re,  db1_data_in_im;		//  Input Data to delay_buffer
logic signed [`WIDTH-1:0] db1_data_out_re, db1_data_out_im;		//  Output Data from delay_buffer

logic signed [`WIDTH-1:0] sdf1_out_re, sdf1_out_im;				//  Ouput Data from SDF
logic	   	 [`LOG_N-1:0] sdf1_out_cnt, nxt_sdf1_out_cnt;							//  SDF Output Data Count
logic					  sdf1_out_start;  						//  Start of SDF Output
logic					  sdf1_out_end; 	   					//  End of SDF Output
logic					  sdf1_out_en;							//  SDF Output Enable
logic					  j_en;									//  Twiddle (-j) Enable
logic signed [`WIDTH-1:0] sdf1_data_out_re, sdf1_data_out_im; 	//  Output Data from 1st SDF

//  Butterfly inputs enable when 'Input Data Count' > 'Delay Depth'
always_ff @(posedge clk) begin
	if (reset) begin
		data_in_cnt <= #1 {`LOG_N{1'b0}};
	end else begin
		data_in_cnt <= #1 data_in_en ? (data_in_cnt + 1'b1) : {`LOG_N{1'b0}};
	end
end

assign bf1_in_en = data_in_cnt[LOG_DEPTH];

//  Set butterfly 'Input Data #0' and 'Input Data #1'
always_comb begin
	bf1_x0_re = bf1_in_en ? db1_data_out_re : {`WIDTH{1'b0}};
	bf1_x0_im = bf1_in_en ? db1_data_out_im : {`WIDTH{1'b0}};
	bf1_x1_re = bf1_in_en ? data_in_re      : {`WIDTH{1'b0}};
	bf1_x1_im = bf1_in_en ? data_in_im      : {`WIDTH{1'b0}};
end

butterfly BF1 (
	.x0_re  (bf1_x0_re	),	//  in
	.x0_im  (bf1_x0_im	), 	//  in
	.x1_re  (bf1_x1_re	),	//  in
	.x1_im  (bf1_x1_im	),	//  in
	.y0_re  (bf1_y0_re	),	//  out
	.y0_im  (bf1_y0_im	),	//  out
	.y1_re  (bf1_y1_re	),	//  out
	.y1_im  (bf1_y1_im	)	//  out
);

//  Set dalay_buffer 'Input Data'
always_comb begin
	db1_data_in_re = bf1_in_en ? bf1_y1_re : data_in_re;
	db1_data_in_im = bf1_in_en ? bf1_y1_im : data_in_im;
end

delay_buffer #(.DEPTH(2**LOG_DEPTH)) DB1 (
	.clk		(clk		),		//  in
	.reset		(reset		),		//  in
	.data_in_re	(db1_data_in_re	),	//  in
	.data_in_im	(db1_data_in_im	),	//  in
	.data_out_re(db1_data_out_re),	//  out
	.data_out_im(db1_data_out_im)	//  out
);

//  SFD outputs enable when 'sdf1_out_cnt' between 'sdf1_out_start' and 'sdf1_out_end'
assign nxt_sdf1_out_cnt = sdf1_out_cnt + 1'b1;
assign sdf1_out_start = (data_in_cnt == 2**LOG_DEPTH);
assign sdf1_out_end = (sdf1_out_cnt == (2**`LOG_N-1));  
//assign j_en = (sdf1_out_cnt[LOG_DEPTH:LOG_DEPTH-1] == 2'b11);
assign j_en = (nxt_sdf1_out_cnt[LOG_DEPTH:LOG_DEPTH-1] == 2'b11);

assign sdf1_out_re = bf1_in_en ? bf1_y0_re : j_en ?  db1_data_out_im : db1_data_out_re;
assign sdf1_out_im = bf1_in_en ? bf1_y0_im : j_en ? -db1_data_out_re : db1_data_out_im;


always_ff @(posedge clk) begin
	if (reset) begin
		sdf1_out_en  <= #1 1'b0;
		sdf1_out_cnt <= #1 {`LOG_N{1'b0}};
	end else begin
		sdf1_out_en  <= #1 sdf1_out_start ? 1'b1 : sdf1_out_end ? 1'b0 : sdf1_out_en;
		sdf1_out_cnt <= #1 sdf1_out_en ? nxt_sdf1_out_cnt : {`LOG_N{1'b0}};
	end
end

always_ff @(posedge clk) begin
	if (reset) begin
		sdf1_data_out_re <= #1 {`WIDTH{1'b0}};
		sdf1_data_out_im <= #1 {`WIDTH{1'b0}};
	end else begin
		sdf1_data_out_re <= #1 sdf1_out_re;
		sdf1_data_out_im <= #1 sdf1_out_im;
	end
end


//--------------------------------------------------------------//
//  2nd radix-2 Single-Path Delay Feedback						//	
//--------------------------------------------------------------//
//===== Reg/Wire Declaration =====//
logic            		  bf2_in_en;							//  Butterfly Input Enable
logic signed [`WIDTH-1:0] bf2_x0_re, bf2_x0_im;					//  Input Data #0 to butterfly
logic signed [`WIDTH-1:0] bf2_x1_re, bf2_x1_im;					//  Input Data #1 to butterfly
logic signed [`WIDTH-1:0] bf2_y0_re, bf2_y0_im;					//  Output Data #0 from butterfly
logic signed [`WIDTH-1:0] bf2_y1_re, bf2_y1_im;					//  Output Data #1 from butterfly

logic signed [`WIDTH-1:0] db2_data_in_re,  db2_data_in_im;		//  Input Data to delay_buffer
logic signed [`WIDTH-1:0] db2_data_out_re, db2_data_out_im;		//  Output Data from delay_buffer

logic signed [`WIDTH-1:0] sdf2_out_re, sdf2_out_im;				//  Ouput Data from SDF
logic        [`LOG_N-1:0] sdf2_out_cnt;							//  SDF Output Data Count
logic					  sdf2_out_start;  						//  Start of SDF Output
logic					  sdf2_out_end;    						//  End of SDF Output
logic					  sdf2_out_en;							//  SDF Output Enable
logic signed [`WIDTH-1:0] sdf2_data_out_re, sdf2_data_out_im;  	//  Output Data from 1st SDF

//===== Combinational =====//
//  Butterfly inputs enable when 'Input Data Count' > 'Delay Constant (M/2)'
assign bf2_in_en = sdf1_out_cnt[LOG_DEPTH-1];

//  Set butterfly 'Input Data #0' and 'Input Data #1'
assign bf2_x0_re = bf2_in_en ? db2_data_out_re : {`WIDTH{1'b0}};
assign bf2_x0_im = bf2_in_en ? db2_data_out_im : {`WIDTH{1'b0}};
assign bf2_x1_re = bf2_in_en ? sdf1_data_out_re: {`WIDTH{1'b0}};
assign bf2_x1_im = bf2_in_en ? sdf1_data_out_im: {`WIDTH{1'b0}};

butterfly BF2 (
	.x0_re  (bf2_x0_re	),	//  in
	.x0_im  (bf2_x0_im	), 	//  in
	.x1_re  (bf2_x1_re	),	//  in
	.x1_im  (bf2_x1_im	),	//  in
	.y0_re  (bf2_y0_re	),	//  out
	.y0_im  (bf2_y0_im	),	//  out
	.y1_re  (bf2_y1_re	),	//  out
	.y1_im  (bf2_y1_im	)	//  out
);

//  Set dalay_buffer 'Input Data'
assign db2_data_in_re = bf2_in_en ? bf2_y1_re : sdf1_data_out_re;
assign db2_data_in_im = bf2_in_en ? bf2_y1_im : sdf1_data_out_im;

delay_buffer #(.DEPTH(2**(LOG_DEPTH-1))) DB2 (
	.clk		(clk		),		//  in
	.reset		(reset		),		//  in
	.data_in_re	(db2_data_in_re	),	//  in
	.data_in_im	(db2_data_in_im	),	//  in
	.data_out_re(db2_data_out_re),	//  out
	.data_out_im(db2_data_out_im)	//  out
);

//  SFD outputs enable when 'sdf2_out_cnt' between 'sdf2_out_start' and 'sdf2_out_end'
assign sdf2_out_start = (sdf1_out_cnt == (2**(LOG_DEPTH-1))) & sdf1_out_en;
assign sdf2_out_end = (sdf2_out_cnt == (2**`LOG_N-1));

assign  sdf2_out_re = bf2_in_en ? bf2_y0_re : db2_data_out_re;
assign  sdf2_out_im = bf2_in_en ? bf2_y0_im : db2_data_out_im;

//===== Sequential =====//
always_ff @(posedge clk) begin
	if (reset) begin
		sdf2_out_en  <= #1 1'b0;
		sdf2_out_cnt <= #1 {`LOG_N{1'b0}};
	end else begin
		sdf2_out_en  <= #1 sdf2_out_start ? 1'b1 : sdf2_out_end ? 1'b0 : sdf2_out_en;
		sdf2_out_cnt <= #1 sdf2_out_en ? (sdf2_out_cnt + 1'b1) : {`LOG_N{1'b0}};
	end
end

always_ff @(posedge clk) begin
	if (reset) begin
		sdf2_data_out_re <= #1 {`WIDTH{1'b0}};
		sdf2_data_out_im <= #1 {`WIDTH{1'b0}};
	end else begin
		sdf2_data_out_re <= #1 sdf2_out_re;
		sdf2_data_out_im <= #1 sdf2_out_im;
	end
end


//--------------------------------------------------------------//
//  Twiddle Multiplcation										//	
//--------------------------------------------------------------//
//  Multiplication
logic	     [1:0]		  	tw_sel;							//  Twiddle Select (2n/n/3n)
logic	     [`LOG_N-3:0]   tw_num;							//  Twiddle Number (n)
logic	     [`LOG_N-1:0]   tw_idx;							//  Twiddle Table Address
logic signed [`WIDTH/2-1:0] tw_re, tw_im;					//  Twiddle Factor

logic						  mul_en; 						//  Multiplication Enable
logic signed [3*`WIDTH/2-1:0] mul1, mul2, mul3;		 		//  Multiplication Intermediate Variables
logic signed [3*`WIDTH/2:0]   mul_re, mul_im;			 	//  Multiplication Output
logic signed [`WIDTH-1:0] 	  mul_data_out_re, mul_data_out_im;//  Multiplication Output Data
logic						  mul_out_en;		 			//  Multiplication Output Data Enable

//assign  tw_sel = sdf2_out_cnt[LOG_DEPTH:LOG_DEPTH-1];
assign  tw_sel = {sdf2_out_cnt[LOG_DEPTH-1], sdf2_out_cnt[LOG_DEPTH]};
assign  tw_num = sdf2_out_cnt << (`LOG_N-LOG_DEPTH-1);
assign  tw_idx = tw_num * tw_sel;

twiddle TW (
	.idx	(tw_idx	),	//  in
	.tw_re	(tw_re  ),	//  out
	.tw_im	(tw_im  )	//  out
);

//  Multiplication is bypassed when twiddle address is 0.
//=====Combinational=====//
always_comb begin
	mul1 = sdf2_data_out_re * (tw_re - tw_im);
	mul2 = sdf2_data_out_im * (tw_re + tw_im);
	mul3 = (sdf2_data_out_re - sdf2_data_out_im) * tw_im;

	mul_re = mul1 + mul3;
	mul_im = mul2 + mul3;
end

//=====Sequential=====//
assign mul_en = (tw_idx != {`LOG_N{1'b0}});

always_ff @(posedge clk) begin
	if (reset) begin
		mul_data_out_re <= #1 {`WIDTH{1'b0}};
		mul_data_out_im <= #1 {`WIDTH{1'b0}};
	end else begin
		if (mul_en) begin
			mul_data_out_re <= #1 mul_re[45:14];
			mul_data_out_im <= #1 mul_im[45:14];
		end else begin
			mul_data_out_re <= #1 sdf2_data_out_re;
			mul_data_out_im <= #1 sdf2_data_out_im;
		end
	end
end

always_ff @(posedge clk) begin
    if (reset) begin
        mul_out_en <= #1 1'b0;
    end else begin
        mul_out_en <= #1 sdf2_out_en;
    end
end

//  No multiplication required at final stage
assign  data_out_en = (LOG_DEPTH == 1) ? sdf2_out_en      : mul_out_en;
assign  data_out_re = (LOG_DEPTH == 1) ? sdf2_data_out_re : mul_data_out_re;
assign  data_out_im = (LOG_DEPTH == 1) ? sdf2_data_out_im : mul_data_out_im;

endmodule

