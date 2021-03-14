function Preamble_Location = Location_of_Preamble(Demodulation_Data)
%The beginning of a subframe is marked by an 8-bit-long preamble.
%The pattern of the preamble is 10001011

%Because of the Costas loop’s ability to track the signal with a 180? phase shift,
%this preamble can occur in an inverted version 01110100

%The authentication procedure checks if the same preamble is repeated every 6 s
%corresponding to the time between transmission of two consecutive subframes.

Preamble = [-1 1 1 1 -1 1 -1 -1]; %preamble = (10001011) - 8 bits long
Correlation_Output = zeros(length(Demodulation_Data)+8+1,1); %in unit of 20 ms
Demodulation_Data_C = [zeros(8,1);Demodulation_Data;zeros(8,1)];
for data_bit = 1:length(Demodulation_Data)+8+1
    Correlation_Output(data_bit) = sum(Preamble.*Demodulation_Data_C(0+data_bit:7+data_bit)');
end; clear data_bit

possible_location = find(abs(Correlation_Output)==8);
NumNavBit_in6sec = 6/0.02;
for loc = 1:length(possible_location)
    if ~isempty(find(possible_location==possible_location(loc)+NumNavBit_in6sec, 1))
        Preamble_Location = possible_location(mod(possible_location-possible_location(loc),300)==0);
    end
end; clear loc

figure; hold on;
plot((1:length(Correlation_Output))*0.02,Correlation_Output)
xlabel('second'); title('Correlation between navigation data and the 8-bit preamble')

if exist('Preamble_Location','var')
    p1 = plot(Preamble_Location*0.02,Correlation_Output(Preamble_Location),'r*');
    legend(p1,'Preamble Location (Beginning of Subframe)')
    Preamble_Location = Preamble_Location-8;
else
    text(0,0,'Error: could not find preamble! BL might be too high!','Color','red','FontSize',14)
    Preamble_Location = single.empty;
end

end