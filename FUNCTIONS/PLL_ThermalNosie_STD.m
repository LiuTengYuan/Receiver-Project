function PLL_ThermalNosie_STD(BL,C_N0,TI)

BL_10 = 10; %Hz
C_N0_vector = 25:50; %dB-Hz
TI_vector = [1,5,10,20].*10^-3; %ms
std_PLL_noise = zeros(length(C_N0_vector),length(TI_vector));
count_TI = 1;
for TI_ = TI_vector
    count_CN0 = 1;
    for C_N0_ = C_N0_vector
        std_PLL_noise(count_CN0,count_TI) = BL_10/10^(C_N0_/10)*(1+1/(2*10^(C_N0_/10)*TI_)); %rad^2
        count_CN0 = count_CN0+1;
    end
    count_TI = count_TI+1;
end
figure; hold on;
plot(C_N0_vector,sqrt(std_PLL_noise));
legend('T_I = 1 ms','T_I = 5 ms','T_I = 10 ms','T_I = 20 ms')
title('Impact fo Thermal Noise (BL = 10 Hz)')
xlabel('C/N0 (dB-Hz)'); ylabel('Tracking Error STD (rad)');

TI_1 = 1; %ms
C_N0_vector = 25:50; %dB-Hz
BL_vector = [5,10,20,40]; %Hz
std_PLL_noise = zeros(length(C_N0_vector),length(BL_vector));
count_BL = 1;
for BL_ = BL_vector
    count_CN0 = 1;
    for C_N0_ = C_N0_vector
        std_PLL_noise(count_CN0,count_BL) = BL_/10^(C_N0_/10)*(1+1/(2*10^(C_N0_/10)*TI_1)); %rad^2
        count_CN0 = count_CN0+1;
    end
    count_BL = count_BL+1;
end
figure; hold on;
plot(C_N0_vector,sqrt(std_PLL_noise));
legend('BL = 5 Hz','BL = 10 Hz','BL = 20 Hz','BL = 40 Hz')
title('Impact of Thermal Noise (T_I = 1 ms)')
xlabel('C/N0 (dB-Hz)'); ylabel('Tracking Error STD (rad)');

end