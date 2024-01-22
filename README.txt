Final_project
├── Matlab
│   ├── input_processing.m		// Prepocessing .wav file and produce .txt file for RTL simulation
│   ├── output_processing.m		// Processing .txt file output from RTL simulation
│   ├── fixed_point_quantization.m	// Fixed-point Quantization to (N, R)
│   └── data
│       ├── p232_188.wav		// Noisy audio file
│       ├── denoised.wav		// Denoised audio file
│       ├── input_sound.txt		// Input file for RTL simulation
│       └── all_ifft_real_out_24.txt	// Output file from RTL simulation
├── Sim
│   ├── hanning.sv			// Hanning window
│   ├── butterfly.sv			// Butterfly architecture for 2 inputs, 2 outputs
│   ├── delay_buffer.sv			// Delay Buffer
│   ├── twiddle.sv			// Twiddle
│   ├── sdf_r22.sv			// Radix-2^2 Single-path Delay Feedback architecture
│   ├── sort.sv				// Bit-reverse sorting
│   ├── fft.sv				// 64-Point FFT (3 stages of sdf_r22)
│   ├── CORDIC_modify.sv		// CORDIC vector mode
│   ├── CORDIC1_modify.sv		// CORDIC rotate mode
│   ├── noise_cancel_seperate.sv	// Noise Cancellation Design
│   ├── ifft.sv				// 64-Point IFFT (3 stages of sdf_r22)
│   ├── top.sv				// Combine CORDIC and Noise Cancellation
│   ├── fft2ifft.sv			// Combine FFT to IFFT
│   ├── hann2ifft.sv			// Top Level architecture
│   ├── tb_d.sv				// Testbench
│   ├── input_sound.txt
│   └── Makefile
└── Syn
    └── Makefile
        ├── scripts
        │   ├── constraints.tcl
        │   └── synth.tcl 
        ├── src
        │   ├── hanning.sv
        │   ├── butterfly.sv
        │   ├── delay_buffer.sv
        │   ├── twiddle.sv
        │   ├── sdf_r22.sv
        │   ├── sort.sv
        │   ├── fft.sv
        │   ├── CORDIC_modify.sv
        │   ├── CORDIC1_modify.sv
        │   ├── noise_cancel_seperate.sv
        │   ├── ifft.sv
        │   ├── top.sv
        │   └── fft2ifft.sv
	├── reports			// Report files
        └── results			// Netlist files
            

########## Input Process in Matlab ##########
1. $cd ./Matlab
2. Run input_processing.m
################ Simulation #################
3. $cp ./data/input_sound.txt ../Sim
4. $cd ../Sim
5. $make
6. $make verdi
7. $cp ./all_ifft_real_out_24.txt ../Matlab/data
################# Synthesis #################
8. $cd ../Syn
9. $make syn
########## View Output in Matlab ############
10. $cd ../Matlab
11. Run ouput_processing.m
12. Open ./data/denoise.wav

