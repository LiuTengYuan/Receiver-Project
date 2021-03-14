function Demodulation_Data = Nav_Data_Demodulation(I,time_total)

Demodulation_Data = zeros(length(I)-1,1);
for data_bit = 2:length(I)
    if I(data_bit) > 0
        Demodulation_Data(data_bit-1) = 1;
    else
        Demodulation_Data(data_bit-1) = -1;
    end
end; clear data_bit
fmt=['Navigation Data: ' repmat(' %1.0f',1,numel(Demodulation_Data))];
fprintf("\nData Demodulation (TI=20ms)\n"+fmt+"\n",Demodulation_Data);
Num_Nav_Bit = ceil(time_total/0.02);
figure; hold on; xlabel('second'); title('Navigation Data Demodulation')
for num = 1:Num_Nav_Bit
    if num~=Num_Nav_Bit
        line(0.02*linspace((num-1),num,2),Demodulation_Data(num)*ones(1,2),'linewidth',3,'color','c')
    else
        line(linspace((num-1)*0.02,time_total,2),Demodulation_Data(num)*ones(1,2),'linewidth',3,'color','c')
    end
end; clear num

end