function PlotPLL_IQ_Vd_Vc(NI,TI,time_total,I,Q,Vd,Vc)

time_slot = (1:NI)*TI; time_slot(end) = time_total;
figure;hold on;plot(time_slot,I(2:end));plot(time_slot,Q(2:end));
legend('I','Q'); xlabel('second'); title('Correlation Output')
figure;plot(time_slot,rad2deg(Vd(2:end))); xlabel('second'); ylabel('degree');
legend('carrier phase error'); title('Discriminator Output (Vd)')
figure;plot(time_slot,Vc(2:end)); xlabel('second'); ylabel('Hz');
legend('carrier phase rate error'); title('Loop Filter Output (Vc)')

% figure; plot(time_slot,Vd_FLL(2:end)); xlabel('second'); ylabel('Hz');
% legend('carrier frequency error'); title('(FLL) Discriminator Output (Vd)')
% Vd_FLL_nobit = Vd_FLL; bit_transition = find(abs(Vd_FLL_nobit)>5e2); %500Hz is doppler frequency search step
% for bit = bit_transition
%     Vd_FLL_nobit(bit) = (Vd_FLL_nobit(bit+1)+Vd_FLL_nobit(bit-1))/2;
% end
% figure; plot(time_slot,Vd_FLL_nobit(2:end)); xlabel('second'); ylabel('Hz');
% legend('carrier frequency error'); title('(FLL) Discriminator Output (Vd) - No Bit Transition')

end