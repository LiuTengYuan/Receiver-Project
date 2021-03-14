function count_cell = Bit_Synchronization(I)

%Bit sychronization aims at determining the start of navigation message
%data bits in order to achieve correlation over 20 ms
%Based on the detection of a change in the sign between 2 successive
%In-Phase prompt (Ip) correlator outputs

%20 is due to the reason that 1 data bit is equalt to 20 PRN coe period
count_cell = zeros(20,1); 
count = 1; I(1) = I(2);
for time = 2:length(I)
    if sign(I(time))~=sign(I(time-1))
        count_cell(count) = count_cell(count)+1;
    end
    count = count+1;
    if count > 20
        count = 1;
    end
end; clear time

figure; bar(count_cell); xticks([1:20]);xlabel('Bin Number'); ylabel('Bin Value'); title('Bit Synchronization')



end