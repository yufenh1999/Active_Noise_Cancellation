%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file prepocesses the input audio file and    % 
% produce the input_sound.txt for RTL input.        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
close;
filename = 'data/p232_188.wav';
[x,Fs] = audioread(filename);

%% Open input_sound.txt
file = fopen('data/input_sound.txt','w');

%% Write overlapped input
window_size = 64;
overlap = window_size / 2;

for i = 1:(2*length(x)/window_size - 1)
    % Selecting a 64-point segment
    segment = x(overlap*(i-1)+1 : overlap*(i+1));
    
    s = fixed_point_quantization(segment, 32, 24);
    bS = dec2bin(s, 32);
    for j = 1:length(s)
        fprintf(file, "%s\n", bS(j, :));
    end

end

fclose(file);
