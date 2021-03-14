clear; close all; clc;
dbstop if error;
addpath(genpath('./FUNCTIONS'));
tic;
% profile on;

%% Parameter Chosen ourselves
simulation_signal = true; % decide if we use loaded signal or generated sigmal
Acquisition = false;
PLLFLL = true;

%% Acquisition (Parallel Code Space Search)
if Acquisition
    AcquisitionFunction(simulation_signal);
end

%% (Now we focus on PRN20 with known Doppler and Time Delay)
Fs = 23.104e6; %Hz (sampling frequency)
Ts = 1/Fs; %second (sampling rate)
IF = 4.348e6; %Hz
L1 = 1575.42e6; %Hz
Doppler = 1755; %Hz (doppler frequency)
time_delay = 8945; %samples chips (code delay)
F_carrier = IF+Doppler; %Hz (carrier frequency)
prn = 20; %(satellite prn)
code = ca_code(prn);
Fc = 1.023e6+Doppler*(1.023e6/L1);
Code_Period = 1023/Fc; %code period duration (second)
nav_bit_delay = 5; % ms (navigation bit delay) [simulated signal]---------> defined
carrier_phase = 40; %deg (carrier delay) [simulated signal]---------------> defined
C_N0 = 45; %carrie-to-noise ratio (dBHz) [simulated signal]---------------> defined
BL = 10; %equivalent bandwidth (Hz)---------------------------------------> defined
Ncp = 1; %Number of Code Period for Integration---------------------------> defined
N_total = 3000; %number of code period------------------------------------> defined
TI = Ncp*Code_Period; %Integration duration (second)
NI = ceil(N_total/Ncp); %Number of Integration
time_total = Code_Period*N_total; %total time (second)
[data_value,data] = create_data_bit(N_total); %data is in unit of chip
signal = Generation_Signal_V2(simulation_signal,time_delay,F_carrier,carrier_phase,...
    code,data,Fc,Ts,TI,Code_Period,N_total,C_N0,nav_bit_delay);
%Received Signal = A*D(Ts*k-time_delay)*C(Ts*k-time_delay)*cos(2*pi*(IF+Doppler)*Ts*k+carrier_phase)+noise
%Local Replica = C(Ts*k-time_delay_hat)*exp^(j*(2*pi*(IF+Doppler_hat)*Ts*k+carrier_phase_hat))

%% DLL


%% PLL & FLL
if PLLFLL
    %In case that there is doppler frequency error (max (500/2)Hz because frequency search step(500 Hz))
    Doppler_error = 0; %Hz
    Doppler = Doppler+Doppler_error;
    Fc = 1.023e6+Doppler*(1.023e6/L1);
    Code_Period = 1023/Fc;
    TI = Ncp*Code_Period;
    
    %In case that there is code phase error (max (1/2)chip because code search search step(1 chip))
    time_delay_error_chip = 0; %chip
    time_delay_error = round(time_delay_error_chip/(Fc*Ts)); %sample
    time_delay = time_delay+time_delay_error;
    
    I = zeros(NI+1,1); Q = zeros(NI+1,1);
    Vc = zeros(NI+1,1); Vd = zeros(NI+1,1); Vd_FLL = zeros(NI+1,1);
    thetda0 = zeros(NI+1,1); phi = zeros(NI+1,1);
    Vc(1) = Doppler; N_prev = 0;
    for time = 1:NI
        if time ~= NI
            N_curr = round(TI*time/Ts); %number of sampling from beginning
        else %in case that in the last integration we don't have complete integration period (TI)
            N_curr = round(N_total*Code_Period/Ts); %number of sampling from beginning
        end
        N = N_curr-N_prev; %number of sampling in current TI period
        k_curr = (N_prev:N_curr-1);
        t_curr = k_curr*Ts;
        N_prev = N_curr;
        k = (0:N-1);
        time_vector_chip = k*Ts*Fc;
        sampling_code = create_code_samples(code, time_vector_chip);
        local_code_timedelay = [sampling_code(end-time_delay+1:end) sampling_code(1:end-time_delay)];
        %local replica carrier(k) = exp(-[2*pi*(IF+Doppler Frequency)*(k*Ts)+carrier phase])
        loc_replica_cos = local_code_timedelay.*cos(2*pi*(IF+Vc(time))*(k*Ts)+thetda0(time));
        loc_replica_sin = local_code_timedelay.*-sin(2*pi*(IF+Vc(time))*(k*Ts)+thetda0(time));
        incoming_singal = signal(k_curr+1);
        
        % I = (A/2)*Data*R(code delay error)*sinc(doppler frequency error*T)*cos(carrier phase error)+NI
        % Q = (A/2)*Data*R(code delay error)*sinc(doppler frequency error*T)*sin(carrier phase error)+NQ
        I(time+1) = 1/N*sum(incoming_singal.*loc_replica_cos);
        Q(time+1) = 1/N*sum(incoming_singal.*loc_replica_sin);
        
        %PLL Discriminator (carrier phase error)
%         Vd(time+1) = atan(Q(time+1)/I(time+1)); %arctangenet (radius)
                Vd(time+1) = (I(time+1)*Q(time+1))/(I(time+1)^2+Q(time+1)^2); %product (radius)
        
        %FLL Discriminator (doppler frequency error)
        %         cross = I(time)*Q(time+1)-I(time+1)*Q(time);
        %         dot = I(time)*I(time+1)+Q(time)*Q(time+1);
        %         Vd_FLL(time+1) = atan2(cross,dot)/TI;
        
        %Loop Filter (third order)
        K1 = (60/23)*BL*TI; K2 = (4/9)*K1^2; K3 = (2/27)*K1^3;
        if time==1
            %Vc(1) = Vc(0) = Doppler; Vd(1) = Vd(0) = 0;
            Vc(time+1) = 2*Doppler-Doppler+(K1+K2+K3)/(2*pi*TI)*Vd(time+1)...
                -(2*K1+K2)/(2*pi*TI)*0+K1/(2*pi*TI)*0;
        else
            Vc(time+1) = 2*Vc(time)-Vc(time-1)+(K1+K2+K3)/(2*pi*TI)*Vd(time+1)...
                -(2*K1+K2)/(2*pi*TI)*Vd(time)+K1/(2*pi*TI)*Vd(time-1);
        end
        
        thetda0(time+1) = thetda0(time)+2*pi*(IF+Vc(time))*(N*Ts);
        
    end; clear time
    
    Plot_Incoming_Signal(simulation_signal,time_total,Code_Period,Ts,Fc,C_N0,F_carrier,carrier_phase,data,code,signal);
    
    count_cell = Bit_Synchronization(I);
    
    if Ncp == 20 %(TI~=20ms)
        Demodulation_Data = Nav_Data_Demodulation(I,time_total);
        if time_total >= 12 %(total time should be at least 12 second to find 2 consecutive preambles)
            Preamble_Location = Location_of_Preamble(Demodulation_Data);
        end
    end
    %Plot IQ Vc Vd (PLL results)
    PlotPLL_IQ_Vd_Vc(NI,TI,time_total,I,Q,Vd,Vc);
    
    %Phase Discriminator Comparision (atan v.s. product)
%     Phase_Discriminator_Comparision(IF,Ts,C_N0); %third input is C_N0, which show how noise affect
    
    %Impact of Thermal Noise
%     PLL_ThermalNosie_STD(BL,C_N0,TI);
end

% profile off; profsave;
toc;
