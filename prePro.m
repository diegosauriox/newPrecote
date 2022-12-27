function [ y4,y3] = prePro( yraw, filtro,filtro2 )
meany=mean(nonzeros(yraw));
bi=yraw==0;
bi=imgaussfilt(bi*10,1);
yraw(bi==10)=meany;
inicio=1000;
y2 = filter(filtro.Bandpass1_10,[yraw(1)*ones(inicio,1),; yraw]);
%y3 = filter(filtro2.Hd_bandpass,y2);
y3=y2(inicio+1:end);
maxi=max(abs(y3));
y4=y3/maxi;

end

