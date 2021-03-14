function [data_value,data] = create_data_bit(N_total)

%1 data period= 20*1023 chips
data_value = randi([0,1],1,ceil(N_total/20))';
for i = 1:ceil(N_total/20)
    if data_value(i)==0
        data_value(i) = 1;
    else
        data_value(i) = -1;
    end
end

data = zeros(1,1023*N_total);
count = 1;
for chip = 1:1023*N_total
   data(chip) = data_value(count);
   if mod(chip,20*1023) == 0
       count = count+1;
   end
end

end