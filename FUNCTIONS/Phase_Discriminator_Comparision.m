function Phase_Discriminator_Comparision(F_carrier,Ts,C_N0)

test_code = ca_code(20);
    [~,test_data] = create_data_bit(1);
    test_data = test_data.*test_data;
    phase_error_vector = -2*pi:0.05:2*pi;
    Vd_atan = zeros(1,length(phase_error_vector));
    Vd_product = zeros(1,length(phase_error_vector));
    count = 1;
    for phase_error = phase_error_vector
        phase_error_rad = rad2deg(phase_error);
        test_signal = Generation_Signal_V2(true,0,F_carrier,phase_error_rad,test_code,test_data,...
            1.023e6,Ts,1e-3,1e-3,1,C_N0);
        test_N = round(1e-3/Ts); test_k = (0:test_N-1);
        test_sampling_code = create_code_samples(test_code, test_k*Ts*1.023e6);
        test_loc_replica_cos = test_sampling_code.*cos(2*pi*F_carrier*(test_k*Ts));
        test_loc_replica_sin = test_sampling_code.*sin(2*pi*F_carrier*(test_k*Ts));
        test_I = 1/test_N*sum(test_signal.*test_loc_replica_cos);
        test_Q = -1/test_N*sum(test_signal.*test_loc_replica_sin);
        Vd_atan(count) = atan(test_Q/test_I);
        Vd_product(count) = (test_I*test_Q)/(test_I^2+test_Q^2); 
        count = count+1;
    end
    figure; hold on; plot(phase_error_vector,Vd_product); plot(phase_error_vector,Vd_atan);
    legend('Product','Atan'); xlabel('Input Phase Error (rad)'); ylabel('Discriminator Output (rad)')
    xlim([-2*pi 2*pi])
    
end