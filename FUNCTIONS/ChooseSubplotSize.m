function size_sp = ChooseSubplotSize(prn_all)
% created in 11/24/2019 by LIU
    switch length(prn_all)
        case num2cell(1,2)
            size_sp = [1,length(prn_all)];
        case num2cell(3,4)
            size_sp = [2,2];
        case num2cell([5,6])
            size_sp = [2,3];
        case num2cell([7,8,9])
            size_sp = [3,3];
        case num2cell([10,11,12])
            size_sp = [3,4];
        case num2cell([13,14,15,16])
            size_sp = [4,4];
        case num2cell([17,18,19,20])
            size_sp = [4,5];
        case num2cell([21,22,23,24,25])
            size_sp = [5,5];
        case num2cell([26,27,28,29,30])
            size_sp = [5,6];
        case num2cell([31,32,33,34,35,36])
            size_sp = [6,6];
        case num2cell(37)
            size_sp = [6,7];
    end
end