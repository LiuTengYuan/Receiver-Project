function signal = Generation_Signal(simulation_signal,time_delay,F_carrier,carrier_phase,sampling_code,Ts,N,N_signal)
% created in 12/27/2019 by LIU
% this function is used to generate received signal by simulated signal or
% loaded signal

if simulation_signal
    %due to code's periodicity, we could express time delay in this way
    one_correaltion_signal = [sampling_code(end-time_delay+1:end) sampling_code(1:end-time_delay)];
    signal_timedelay = repmat(one_correaltion_signal,1,N_signal);
    %applying doppler frequency into generated siganl
    k_signal = (0:N*N_signal-1);
    signal = signal_timedelay.*cos(2*pi*F_carrier*(k_signal*Ts)+deg2rad(carrier_phase*ones(1,length(k_signal))));
else
    %Reads the "test_real_long.dat" file (GPS data)
    fileIn  = './DATA/test_real_long.dat';
    duration = N*N_signal; %total number of sampling (chips)
    signal = DataReader(fileIn, duration)'; % 1.5 bits ADC (samples take 3 values: -1,0,1)
end

end