module CORDIC_modify(
	input		   clk, reset,
    input          enable_in,
	input	    signed [31:0] x_re, x_im,
    output  logic         enable_out,
	output	logic signed [31:0] theta,
    output  logic signed [31:0] theta_out,
	output  logic signed [31:0]    s_re_out,
	output  logic [1:0] 	k_cordic_out
);

	//===== Reg/Wire Declaration =====
	logic  signed	[31:0] x0, x1_vec, x2_vec, x3_vec, x4_vec, x5_vec;

	logic  signed	[31:0] y0, y1_vec, y2_vec, y3_vec, y4_vec, y5_vec;

	logic  signed	[31:0] z0, z1_vec, z2_vec, z3_vec, z4_vec, z5_vec;
	
	logic  signed	[31:0] PI;

	logic 		 [1:0]  k0, k1, k2, k3, k4, k5;
	logic enable1, enable2, enable3, enable4;
    //logic signed [31:0] theta_out;

	//===== Combinational =====
	//Glue Logic
	assign PI = 32'b00000011001001000011111101101011;	//pi in (32, 24)
	//assign PI1 = 36'b000011001001000011111101101010100010;
	assign z0 = 32'b0;
	assign k_cordic_out = k5;
	assign s_re_out = x5_vec;
    assign theta_out =  z5_vec;
	always_comb begin
		if (x_re[31] == 0 && x_im[31] == 0) begin
			x0 = x_re;
			y0 = x_im;
			k0 = 2'd0;
		end
		else if (x_re[31] == 1 && x_im[31] == 0) begin
			x0 = x_im;
			y0 = -x_re;
			k0 = 2'd1;
		end
		else if (x_re[31] == 1 && x_im[31] == 1) begin
			x0 = -x_re;
			y0 = -x_im;
			k0 = 2'd2;
		end
		else begin
			x0 = -x_im;
			y0 = x_re;
			k0 = 2'd3;
		end
	end

	//===== Sequential ======
	CORDIC_stage0 vec_stage1(.clk(clk), .reset(reset), .enable_in(enable_in), .x_in(x0), .y_in(y0), .z_in(z0), .stage(4'd0), .k_in(k0), .enable_out(enable1),
       				.x_out(x1_vec), .y_out(y1_vec), .z_out(z1_vec), .k_out(k1));
	CORDIC_stage0 vec_stage2(.clk(clk), .reset(reset), .enable_in(enable1), .x_in(x1_vec), .y_in(y1_vec), .z_in(z1_vec), .stage(4'd1), .k_in(k1), .enable_out(enable2),
				.x_out(x2_vec), .y_out(y2_vec), .z_out(z2_vec), .k_out(k2));
	CORDIC_stage0 vec_stage3(.clk(clk), .reset(reset), .x_in(x2_vec), .y_in(y2_vec), .z_in(z2_vec), .stage(4'd2), .k_in(k2), .enable_in(enable2), .enable_out(enable3),
				.x_out(x3_vec), .y_out(y3_vec), .z_out(z3_vec), .k_out(k3));
	CORDIC_stage0 vec_stage4(.clk(clk), .reset(reset), .x_in(x3_vec), .y_in(y3_vec), .z_in(z3_vec), .stage(4'd3), .k_in(k3), .enable_in(enable3), .enable_out(enable4),
				.x_out(x4_vec), .y_out(y4_vec), .z_out(z4_vec), .k_out(k4));
	CORDIC_stage0 vec_stage5(.clk(clk), .reset(reset), .x_in(x4_vec), .y_in(y4_vec), .z_in(z4_vec), .stage(4'd4), .k_in(k4), .enable_in(enable4), .enable_out(enable_out),
				.x_out(x5_vec), .y_out(y5_vec), .z_out(z5_vec), .k_out(k5));

	
	always_comb begin

	case (k5)
		2'd0: 	begin
			theta = z5_vec;
		end
		2'd1:	begin
			theta = z5_vec + (PI >> 1);
		end
		2'd2:	begin
			theta = z5_vec  + PI;
		end
		2'd3:	begin
			theta =  z5_vec  + 32'b00000100101101100101111100100000;// (32, 24) 3/2pi
		end
		default:begin
			theta =  z5_vec ;
		end


    	endcase
	end

/*
	always_ff @(posedge clk) begin
		if (reset) begin
	
			theta <= 32'b0;
			temp <= 32'b0;
		end
		else begin
			//Glue Logic
			case (k5)
				2'd0: 	begin
						theta <= z5_vec;
					end
				2'd1:	begin
						theta <= z5_vec + (PI >> 1);
					end
				2'd2:	begin
						theta <= z5_vec  + PI;
					end
				2'd3:	begin
						theta <=  z5_vec  + 32'b00100101101100101111100011111110;// (34,30) 3/2pi
					end
				default:begin
						theta <=  z5_vec ;
					end


    			endcase
			    temp <= theta;
		end
*/
//end

endmodule


module CORDIC_stage0(
	input		   clk, reset,
    input          enable_in,
	//input		   [3:0]  mode,
	input	    signed [31:0] x_in, y_in,	//x, y is in (32, 30)
	input	    signed [31:0] z_in, 	//z is in (32, 30)
	input		   [3:0]  stage,
	input		   [1:0]  k_in, 
    output  logic  enable_out,
	output	logic signed [31:0] x_out, y_out,
	output 	logic signed [31:0] z_out,
	output	logic signed [1:0]  k_out
);

	//===== Reg/Wire Declaration =====
	logic		[8:0]   cnt;
	logic		[4:0]	offset;
	logic signed 	[31:0] 	x, y, nxt_x, nxt_y;
	logic signed 	[31:0] 	nxt_x_out, nxt_y_out;
	logic signed 	[31:0] 	z, nxt_z, dz;
	//reg signed	control;
	logic signed	[31:0]	SCALING_FAC;
	logic signed	[63:0]	x_temp, y_temp;
	integer i;

	//===== Combinational =====
	assign offset = (stage << 2) + (stage << 1);
	assign SCALING_FAC = 32'd10188015;

	always_comb begin
		//Initialization
		x = x_in;
		y = y_in;
		z = z_in;
		
		//Run 3 for loops in each stage
		for (i=0; i<6; i=i+1) begin
			
			//Look Up Table
			case (offset + i) //redo
					5'b00000: dz = 32'b00000000110010010000111111011011;
					5'b00001: dz = 32'b00000000011101101011000110011100;
					5'b00010: dz = 32'b00000000001111101011011011101100;
					5'b00011: dz = 32'b00000000000111111101010110111011;
					5'b00100: dz = 32'b00000000000011111111101010101110;
					5'b00101: dz = 32'b00000000000001111111111101010101;
					5'b00110: dz = 32'b00000000000000111111111111101011;
					5'b00111: dz = 32'b00000000000000011111111111111101;
					5'b01000: dz = 32'b00000000000000010000000000000000;
					5'b01001: dz = 32'b00000000000000001000000000000000;
					5'b01010: dz = 32'b00000000000000000100000000000000;
					5'b01011: dz = 32'b00000000000000000010000000000000;
					5'b01100: dz = 32'b00000000000000000001000000000000;
					5'b01101: dz = 32'b00000000000000000000100000000000;
					5'b01110: dz = 32'b00000000000000000000010000000000;
					5'b01111: dz = 32'b00000000000000000000001000000000;
					5'b10000: dz = 32'b00000000000000000000000100000000;
					5'b10001: dz = 32'b00000000000000000000000010000000;
					5'b10010: dz = 32'b00000000000000000000000001000000;
					5'b10011: dz = 32'b00000000000000000000000000100000;
					5'b10100: dz = 32'b00000000000000000000000000010000;
					5'b10101: dz = 32'b00000000000000000000000000001000;
					5'b10110: dz = 32'b00000000000000000000000000000100;
					5'b10111: dz = 32'b00000000000000000000000000000010;
					5'b11000: dz = 32'b00000000000000000000000000000001;
					5'b11001: dz = 32'b00000000000000000000000000000000;
					5'b11010: dz = 32'b00000000000000000000000000000000;
					5'b11011: dz = 32'b00000000000000000000000000000000;
					5'b11100: dz = 32'b00000000000000000000000000000000;
					5'b11101: dz = 32'b00000000000000000000000000000000;

					default:  dz = 32'd0;
			endcase
			
			if (y[31]) begin
				nxt_x = x - (y >>> (offset + i));
				nxt_y = y + (x >>> (offset + i));
				nxt_z = z - dz;
			end 
			else begin
				nxt_x = x + (y >>> (offset + i));
				nxt_y = y - (x >>> (offset + i));
				nxt_z = z + dz;
			end 

			//Renew x, y, z value
			x = nxt_x;
			y = nxt_y;
			z = nxt_z;
		end
	end
	
	always_comb begin
		if (stage == 4'd4) begin
			x_temp = (x * SCALING_FAC);
			y_temp = (y * SCALING_FAC);
			nxt_x_out = x_temp[55:24];
			nxt_y_out = y_temp[55:24];
		end
		else begin
			x_temp = {32'b0, x};
			y_temp = {32'b0, y};
			nxt_x_out = x_temp[31:0];
			nxt_y_out = y_temp[31:0];
		end
	end

	//===== Sequential =====
	always_ff @(posedge clk) begin
		if (reset) begin
			cnt   <= 9'b0;
			x_out <= 32'b0;
			y_out <= 32'b0;
			z_out <= 32'b0;
			k_out <= 2'b0;
			enable_out <= 1'b0;
		end
		else begin
			cnt   <= cnt + 9'b1;	
			x_out <= nxt_x_out;
			y_out <= nxt_y_out;
			if (cnt >= stage ) begin
				z_out <= nxt_z;
				enable_out <= enable_in;
			end
			else begin
				z_out <= 32'b0;
				enable_out <= enable_in;
			end
			k_out <= k_in;
		end
	end

endmodule

