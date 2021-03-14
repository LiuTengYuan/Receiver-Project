function Plot_Incoming_Signal(simulation_signal,time_total,Code_Period,Ts,Fc,C_N0,F_carrier,carrier_phase,data,code,signal)

figure;
if simulation_signal
    sampling_data = create_code_samples(data,(0:round(time_total/Ts)-1)*Ts*Fc);
    subplot(2,3,1);plot((1:length(sampling_data))*Ts,sampling_data,'linewidth',3,'color','g')
    xlabel('second'); title('Navigation Data Bit')
    sampling_code = create_code_samples(code,(0:round(Code_Period/Ts)-1)*Ts*Fc);
    subplot(2,3,2);plot((1:length(sampling_code))*Ts,sampling_code,'linewidth',3,'color','m')
    xlabel('second'); title('PRN Code (1 code period)')
    sampling_carrier = cos(2*pi*F_carrier*((0:round((1/Fc)/Ts)-1)*Ts)+deg2rad(carrier_phase*ones(1,round((1/Fc)/Ts))));
    subplot(2,3,3);plot((1:length(sampling_carrier))*Ts,sampling_carrier,'linewidth',3,'color','c')
    xlabel('second'); title('Carrier (1 chip period)')
    subplot(2,3,[4:6]);plot((1:length(signal))*Ts,signal,'linewidth',3,'color','r')
    xlabel('second'); title(['Simulated Signal (C/N0 = ',num2str(C_N0),' dBHz)'])
else
    subplot(2,1,1);plot((1:length(signal))*Ts,signal,'linewidth',3,'color','k')
    xlabel('second'); title('Real Signal')
    subplot(2,1,2);plot((1:round((10/Fc)/Ts))*Ts,signal(1:round((10/Fc)/Ts)),'linewidth',3,'color','k')
    xlabel('second'); title('Real Signal (10 chip period)')
end
    
end