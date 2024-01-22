%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file pocesses the output txt file from RTL.  % 
% Then compare the waveform of original audio signal%
% and RTL output signal, and produce the audio file %
% of out RTL output.                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
close;

%% Read all_ifft_real_out_24.txt
y_re = regexp(fileread('data/all_ifft_real_out_24.txt'), '\r?\n', 'split');    % Modify to the RTL output file
y_re = str2double(y_re.') .* 2^(-24);

%% Original audio signal
filename = 'data/p232_188.wav';  % Modify to the noised audio file
[x,Fs] = audioread(filename);
player_orig = audioplayer(x, Fs); 
play(player_orig);

%% Add back output data
window_size = 64;
overlap = window_size / 2;

y = zeros(ceil(length(y_re) / 2) + overlap, 1);
for i = 1:(length(y_re)/window_size)
    % Selecting a 64-point segment
    y_seg = y_re(window_size*(i-1)+1 : window_size*(i));
    y(overlap*(i-1)+1 : overlap*(i+1)) = y(overlap*(i-1)+1 : overlap*(i+1)) + y_seg;

end
% y = y/max(abs(y));    % Normalize to [-1, +1]

player_deno = audioplayer(y, Fs); 
play(player_deno);

%% Plot the noised and denoised audio signal
figure(1);
subplot(2, 1, 1);
plot(x);
title("Original Signal");

subplot(2, 1, 2);
plot(y);
title("Denoised Signal");

%% Save the denoised audio file
filename_deno = 'data/denoised.wav';
audiowrite(filename_deno,y,Fs);
