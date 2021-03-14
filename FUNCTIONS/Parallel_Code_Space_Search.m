function Ti = Parallel_Code_Space_Search(sampling_code,fd_vector,N,NI,signal,IF,time_vector_second)
% created in 11/24/2019 by LIU
% this function is used to deliver acquisition by means of FFt and circuler cross
% correaltionm 

local_replica = sampling_code;
T_nc = zeros(length(fd_vector),N,NI); %noncoherent integration
for m = 1:NI
    signal_correlation = signal(N*(m-1)+1:N*m);
    T_c = zeros(length(fd_vector),N); %coherent integration
    for fd = 1:length(fd_vector)
        local_replica_carrier_cos = cos(2*pi*(IF+fd_vector(fd))*time_vector_second);
        local_replica_carrier_sin = sin(2*pi*(IF+fd_vector(fd))*time_vector_second);
        I = signal_correlation.*local_replica_carrier_cos;
        Q = signal_correlation.*local_replica_carrier_sin;
        T_c(fd,:) = abs(ifft(fft(I+1i.*Q).*conj(fft(local_replica)))); %.^2?????????
    end
    T_nc(:,:,m) = T_c;
end
Ti = sum(T_nc,3)';

end