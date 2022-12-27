function [frec] = frec_fun(yin)
Fs = 100;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(yin);             % Length of signal
if mod(L,2)>0
    L=L-1;
    y=yin(1:(end-1));
else
    y=yin;
end

Y = abs(fft(y)).^2;

P1 = Y(1:L/2+1);
f = Fs*(0:(L/2))/L;
[m,i]=max(P1);
frec=f(i);
ploti=0;
if ploti==1
    plot(f,P1);
    hold on;
    plot(frec,m,'o');
    title('Single-Sided Amplitude Spectrum of X(t)')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
end


end

