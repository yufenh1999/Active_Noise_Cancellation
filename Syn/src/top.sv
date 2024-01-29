`include "CORDIC_modify.sv"
`include "CORDIC1_modify.sv"

`include "noise_cancel_seperate.sv"
module top( 
    input  clk, reset,
    input  enable_in,
    input  signed [31:0] x_re, x_im,
    output logic enable_out, 
    output logic signed [31:0] x_re_out, x_im_out
);

    logic enable_connect, enable_connect1;
    logic signed [31:0] theta_connect, theta_connect1;
    logic [31:0] pre_theta_connect, pre_theta_connect1;
    logic [1:0] k_connect, k_connect1;
    logic [31:0] real_connect, real_connect1;

CORDIC_modify CORDIC( .clk(clk), .reset(reset), .enable_in(enable_in), .x_re(x_re), .x_im(x_im), .enable_out(enable_connect), .theta(theta_connect), 
		.theta_out(pre_theta_connect), .s_re_out(real_connect), .k_cordic_out(k_connect));

noise_cancel_seperate noise_cancel( .clk(clk), .reset(reset), .x_enable(enable_connect), .x_R(real_connect), .x_theta(theta_connect), 
				.x_theta_first_cord(pre_theta_connect), .x_k(k_connect), .s_R(real_connect1), .s_theta(theta_connect1), 
				.s_theta_first_cord(pre_theta_connect1), .s_k(k_connect1), .s_enable(enable_connect1));

CORDIC1 CORDIC1( .clk(clk), .reset(reset), .enable_in(enable_connect1), .s_re(real_connect1), .s_theta(pre_theta_connect1), 
		 	.k_in(k_connect1), .enable_out(enable_out), .x_re_out(x_re_out), .x_im_out(x_im_out));


endmodule 
