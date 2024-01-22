function m = fixed_point_quantization(x, N, R)
    m = round(x * (2^R));
    if m < -2^(N-1)
        m = -2^(N-1);
    elseif m > 2^(N-1) - 1
        m = 2^(N-1) - 1;
    end
end