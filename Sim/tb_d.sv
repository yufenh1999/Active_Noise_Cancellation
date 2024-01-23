`define NUM_SIGNAL 367678
`timescale 100ns/10ns
`define bit_length 32

module tb_CORDIC();

	logic                   clk,reset;
    logic                   enable_in;
    logic signed [`bit_length-1:0] in_data;
    logic                   enable_out;
    logic signed [`bit_length-1:0] ifft_out_re, ifft_out_im;


	logic stop;
    integer f_real, f_imag;
	logic [20:0] cycle;

	hann2ifft H0(
    .clk(clk),
	.reset(reset),
	.enable_in(enable_in),
	.in_data(in_data),
	.enable_out(enable_out),
	.ifft_out_re(ifft_out_re),
	.ifft_out_im(ifft_out_im)
    );

  
    logic [31:0] x_mem [0:`NUM_SIGNAL-1];

	always begin
		#10
		clk=~clk;
	end

	initial begin
		$dumpvars;
		cycle = 0;
		stop = 0;
		clk = 0;
		enable_in = 0;
		reset = 1'b1;
		@(negedge clk);
		@(negedge clk);
        
		$readmemb("input_sound.txt", x_mem);

		
		@(negedge clk);
		reset = 0;
		@(negedge clk);
	   
		
        for (int i = 0; i<`NUM_SIGNAL-1; i++) begin
			@(negedge clk);
			enable_in = 1'b1;
			in_data = x_mem[i];
        end
		
		@(negedge clk);
		enable_in = 1'b0;
		for (int i = 0; i<1024; i++) begin
			@(negedge clk);
		end
		stop = 1;
        

	end
  
    initial begin
         f_real = $fopen("all_ifft_real_out_24.txt", "w");
         f_imag = $fopen("all_ifft_imag_out_24.txt", "w");


         while (~stop) begin
             @(negedge clk)
            if (enable_out) begin
	 			cycle = cycle + 1;
                $fwrite(f_real, "\n", ifft_out_re);
                $fwrite(f_imag, "\n", ifft_out_im);
				//$fwrite(f_count, x_im_out);
	 		end
         end
	 @(negedge clk)
	 $fclose(f_real);
	 $fclose(f_imag);
     $finish;
     end

endmodule


