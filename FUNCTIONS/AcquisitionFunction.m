function AcquisitionFunction(simulation_signal)

% L1 C/A code length is length-1023 Gold codes, and code is generated at 1.023
% MHz (Fc); therefore, one sequence of PRN code is 1 ms (Ti)
Fs = 23.104e6; %Hz (sampling frequency)
Ts = 1/Fs; %second (sampling rate)
IF = 4.348e6; %Hz
L1 = 1575.42e6; %Hz
Fc = 1.023e6; %Hz
Ti = 1e-3; %second (correlation duration=one PRN code period)
N = round(Ti/Ts); %number of sampling
NI = 10; %number of correlation (noncoherent integration)
k = (0:N-1); kI = (0:N*NI-1);
%k*Ts->sampling second during Ti
time_vector_second = k*Ts;
%k*Ts*Fc->sampling chips during Ti
time_vector_chip = k*Ts*Fc;

%typically, the probability of flase alarm is tken equal to the inverse of
%the number of code chips: 1e-3 for GPS C/A
P_FA = 1e-3;
%thermal noise power for GPS
N0 = -111; %(dBm) %????????????????????????????????????????????????????????
%thermal noise power at correlator output(sigma2_N)????????????????????????
if simulation_signal
    Threshold_Acq = 10;%for NI=10 %????????????????????????????????????????
else
    Threshold_Acq = 3; %???????????????????????????????????????????????????
end

%simulated signal setting up
Doppler = 1755; %Hz (doppler frequency)
time_delay = 8945; %samples chips (code delay)
F_carrier = IF+Doppler; %Hz (carrier frequency)
carrier_phase = 40; %deg (carrier delay)
prn = 20; %(satellite prn)
code = ca_code(prn);
%sampling version of GPS L1 C/A code PRN satellite
sampling_code = create_code_samples(code, time_vector_chip);
%Received Signal (loaded from file or generatd ourselves)
signal = Generation_Signal(simulation_signal,time_delay,F_carrier,carrier_phase,sampling_code,Ts,N,NI);
% doppler frequency sweep (+-5kHz in steps of 0.5kHz); frequency search steps = 1/(2*TI) (Hz)
% code phase sweep (1023 chips); code phase search step = 1 (chip)
fd_vector = (-5000:500:5000);
T_all = zeros(N,length(fd_vector),37); prn_all = zeros(37,1); T_ratio = zeros(37,1);
count = 0;
for PRN = 1:37
    code = ca_code(PRN);
    %sampling version of GPS L1 C/A code PRN satellite
    sampling_code = create_code_samples(code, time_vector_chip);
    T = Parallel_Code_Space_Search(sampling_code,fd_vector,N,NI,signal,IF,time_vector_second);
    T_ratio(PRN) = max(max(T))/mean(mean(T));
    %         NoisePower = mean(mean(T));
    %         Threshold_Acq_N = chi2inv((1-P_FA),2*NI);
    %         Threshold_Acq = NoisePower*Threshold_Acq_N;
    %         if any(T>Threshold_Acq)
    if T_ratio(PRN) > Threshold_Acq
        count = count+1;
        T_all(:,:,count) = T;
        prn_all(count) = PRN;
    end
end; clear PRN
T_all = T_all(:,:,1:count);
prn_all = prn_all(1:count);
if ~all(prn_all)
    fprintf('Not find a satellite from signals!\n')
    return
end

size_sp = ChooseSubplotSize(prn_all);
for num  =1:length(prn_all)
    subplot(size_sp(1),size_sp(2),num)
    surf(fd_vector, k, T_all(:,:,num));
    shading interp
    title(['Acquisition ','PRN',int2str(prn_all(num))])
    xlabel('doppler frequency (Hz)')
    ylabel('code delay (samples)')
end; clear num

end