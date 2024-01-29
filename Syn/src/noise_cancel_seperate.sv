//This version calculate the mean noise with 64 data. Seperate the noise data.

`define bit_length 32
`define window 64

module noise_cancel_seperate(
	input									clk, reset,
	input									x_enable,
	input signed		[`bit_length-1:0] 	x_R,
	input signed		[`bit_length-1:0]	x_theta, x_theta_first_cord,
	input				[1:0]				x_k,
	
	output logic signed [`bit_length-1:0] 	s_R,
	output logic signed	[`bit_length-1:0]	s_theta, s_theta_first_cord,
	output logic 		[1:0]				s_k,
	output logic signed						s_enable
);

	logic signed [`bit_length-1:0] noise 	[`window-1:0];
	logic signed [`bit_length-1:0] n_noise 	[`window-1:0];
	
	logic init, n_init;

	logic signed [`bit_length-1:0] h;
	logic signed [`bit_length-1:0] h_r;

	logic signed [`bit_length-1:0] n_s_R;
	logic signed [`bit_length-1:0] n_s_theta, n_s_theta_first_cord;
	
	logic [1:0]	n_s_k;
	logic n_s_enable;

	logic [5:0] counter, n_counter;	//6 bit, 0-63 

	


	always_comb begin
		//default
		n_counter = 0;
		for (int i = 0; i < `window; i++) begin
			n_noise[i] = noise[i];
		end

		if (x_enable) begin
			n_counter = counter + 1'b1;
		end

		//initial signal for noise
		if (counter==6'd63) begin
			n_init = 1'b1;
		end
		else begin
			n_init = init;
		end

		//initial noise
		if (init==1'b0 && x_enable) begin
			n_noise[counter] = x_R;
		end

		//noise reduction
		h = x_R - noise[counter];
		
		if(h[31]) begin
			h_r = 0;
		end
		else begin
			h_r = h;
		end


		if (init==1'b0 && x_enable) begin
			n_s_R = 0;
		end
		else if (x_enable) begin
			if(h_r > noise[counter])begin
				n_s_R = h_r;
			end
			else begin
				n_s_R = 0;
			end
		end
		else begin
			n_s_R = 0;
		end

		//pass through
		if (x_enable)begin
			n_s_theta 				= x_theta;
			n_s_theta_first_cord 	= x_theta_first_cord;
			n_s_k 					= x_k;
			n_s_enable 				= x_enable;
		end
		else begin
			n_s_theta 				= 0;
			n_s_theta_first_cord 	= 0;
			n_s_k 					= 0;
			n_s_enable 				= 0;
		end


	end

	always_ff @(posedge clk) begin
    	if (reset) begin
			counter <= 0;
			init <= 0;
			for (int i = 0; i < `window; i++) begin
				noise[i] <= 0;
			end

			s_enable <= 0;
			s_R <= 0;
			s_theta <= 0;
			s_theta_first_cord <= 0;
			s_k <= 0;
		end

		else begin
			counter <= n_counter;
			init <= n_init;
			for (int i = 0; i < `window; i++) begin
				noise[i] <= n_noise[i];
			end

			s_enable <= n_s_enable;
			s_R <= n_s_R;
			s_theta <= n_s_theta;
			s_theta_first_cord <= n_s_theta_first_cord;
			s_k <= n_s_k;
		end
	end

	endmodule
