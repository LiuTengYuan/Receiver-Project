function signal = Generation_Signal_V2(simulation_signal,time_delay,F_carrier,carrier_phase,...
    code,data,Fc,Ts,TI,Code_Period,N_total,C_N0,nav_bit_delay)
% created in 12/27/2019 by LIU
% this function is used to generate received signal by simulated signal or
% loaded signal

N_all = round(Code_Period*N_total/Ts); %total number of sampling (chips)

% In MATLAB, there are two method to create white gaussain noise to signal(wgn or awgn)
%SNR(RF filter) = C/(N0*B) -----------------------------------------------> in our case
%SNR(correlator output) = (C/2)/(N0/(4*TI))
%Correlation Gain = SNR(correaltion output)/SNR(RF filter) = 2*TI*B
B = 2*Fc; % bandwidth of RF front-end filter (B>=2*Fc)
A = 1; C = A^2/2; N0 = C/10^(C_N0/10); noise_power = 10*log10(N0*B); noise = wgn(N_all,1,noise_power)';
SNR = 10*log10(10^(C_N0/10)/B);


if simulation_signal
    k_all = (0:N_all-1);
    time_vector_chip = k_all*Ts*Fc;
    repeted_code = repmat(code,1,N_total);
    sampling_code = create_code_samples(repeted_code, time_vector_chip);
    nav_bit_delay_chip = nav_bit_delay*1023;
    data = [data(end-nav_bit_delay_chip+1:end) data(1:end-nav_bit_delay_chip)];
    sampling_data = create_code_samples(data, time_vector_chip);
    %due to code's periodicity, we could express time delay in this way
    data_timedelay = [sampling_data(end-time_delay+1:end) sampling_data(1:end-time_delay)];
    signal_timedelay = [sampling_code(end-time_delay+1:end) sampling_code(1:end-time_delay)];
%     signal = A*data_timedelay.*signal_timedelay.*cos(2*pi*F_carrier*(k_all*Ts)+...
%         deg2rad(carrier_phase*ones(1,length(k_all))))+noise;
    signal_no_noise = data_timedelay.*signal_timedelay.*cos(2*pi*F_carrier*(k_all*Ts)+...
        deg2rad(carrier_phase*ones(1,length(k_all))));
    signal = awgn(signal_no_noise,SNR,'measured');

else
    %Reads the "test_real_long.dat" file (GPS data)
    fileIn  = './DATA/test_real_long.dat';
    duration = N_all;
    signal = DataReader(fileIn, duration)'; % 1.5 bits ADC (samples take 3 values: -1,0,1)
end

end