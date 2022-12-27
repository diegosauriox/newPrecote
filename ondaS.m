function [ iS] = ondaS(varargin)
%ondaS detecta el arribo de la onda S de una señal sísmica entregando 
%el índice de la señal.
%   iS=ondaS(signal) asume frec. muestreo 100Hz
%   iS=ondaS(signal,timeVector) utiliza el vector de tiempo
%   iS=ondaS(signal,timeVector,plotFlag) con 1 para mostrar figuras
%   iS=ondaS(signal,timeVector,plotFlag,sRealTime) tiempo real de S 
%   iS=ondaS(signal,timeVector,plotFlag,sRealTime,ZEN) 1,2ó3 para componente 
%   See also ondaP, PREPRO, STALTA.

senal=varargin{1};
N=length(senal);
fs=100;
switch nargin
    case 1
        t=0:.01:(N-1)/100;
        showplots=0;
        isSReal=0;
        eje=1;
    case 2
        t=varargin{2};
        showplots=0;
        isSReal=0;
        eje=1;
    case 3
        t=varargin{2};
        showplots=varargin{3};
        isSReal=0;
        eje=1;
    case 4
        t=varargin{2};
        showplots=varargin{3};
        isSReal=1;
        sReal=varargin{4};
        eje=1;
    case 5
         t=varargin{2};
        showplots=varargin{3};
        sReal=varargin{4};
        if isempty(sReal) || sReal==0
            isPReal=0;
        else
            isPReal=1;
        end
        if length(varargin{5})>1
            eje=0;
            inputs=varargin{5};
        nsc=inputs(1);
        g=inputs(2);
        else
            eje=varargin{5};
        end
        
end

%%
fs=100;
switch eje
        case 0
        nsc=nsc;
    case 1
        nsc=300;
    case 2
        nsc=200;
    case 3
        nsc=500;
        
end
nov = nsc-1;
nff = 1024;
[X1,k1,m]=spectrogram(senal,nsc,nov,nff,fs);
k=k1;
X=X1;
S=(abs(X').^2);
Smin=min(min(S));
Smax=max(max(S));
Sn=(S-Smin)/(Smax-Smin);
Sn_db=10*log10(Sn);

if nargin>3
[~,iS]=min(abs(m-sReal));
end
%%
u=mean2(Sn);

B=Sn>=u;
Su=Sn.*B;
Su_db=10*log10(Su);
Su_db(B==0)=-100;

%%
K=length(k);
Ev=sum(Su,2);

Evmin=min(Ev);
Evmax=max(Ev);
Evn=(Ev-Evmin)/(Evmax-Evmin);




%%
v=sum(B,2);

vmin=min(v);
vmax=max(v);
vn=(v-vmin)/(vmax-vmin);

SE=vn.*Evn;
SE=SE./max(SE);

pmax=sum(SE);
Evmax=sum(Evn);
vmax=sum(vn);
for im=1:length(m)
    p(im)=sum(SE(1:im))/pmax;
    Evn_sum(im)=sum(Evn(1:im))/Evmax;
    vn_sum(im)=sum(Evn(1:im))/vmax;
end

%%
switch eje
    case 0
        y=Evn_sum;
           y_f=imgaussfilt(y,g);
    case 1
        y=p;
        y_f=imgaussfilt(y,25);
    case 2
        y=Evn_sum;
        y_f=imgaussfilt(y,70);
    case 3
        y=p;
        y_f=imgaussfilt(y,50);
end
SE_g=imgaussfilt(SE,25);


%%
 m2 = (m-min(m))./(max(m)-min(m)); 
y_f = (y_f-min(y_f))./(max(y_f)-min(y_f));    % normalización de y
y_p = gradient(y_f, m2(2)-m2(1));       % derivada de y
y_p=y_p./max(abs(y_p));
y_pp = gradient(y_p, m2(2)-m2(1));    % segunda derivada de y

y_pp_n=y_pp./max(abs(y_pp));

y_p2 = gradient(y, m2(2)-m2(1));       % derivada de y sin filtro
y_pp2 = gradient(y_p2, m2(2)-m2(1));
y_p2=y_p2./max(abs(y_p2));
y_pp2=y_pp2./max(abs(y_pp2));

SE_g_d=gradient(SE_g, m2(2)-m2(1)); 


SE_d=gradient(SE,m2(2)-m2(1));
y_pp=y_pp./max(abs(SE_d));
SE_d=SE_d./max(abs(SE_d));


vn_d=gradient(vn,m2(2)-m2(1));
vn_d=vn_d./max(abs(vn_d));


Evn_d=gradient(Evn,m2(2)-m2(1));
Evn_d=Evn_d./max(abs(Evn_d));


[~, imS] = max(y_pp);
[~,iS]=min(abs(m(imS)-t));

%%
if showplots==1
    
    %{
    % figure
    subplot(2,3,[1 4])
    plot(t,senal)
    hold on;
    title('Señal original')
    
    plot([t(iS) t(iS)],[-1 1],'r-')
    if isSReal==1
        plot([sReal sReal],[-1 1],'k-')
    end
    legend('Señal','P predicción','P Real')
    
    subplot(2,3,2)
    surf(m, k, Su_db');
    ylim([0 20])
    shading flat
    view(2);
    hold on
    if isSReal==1
        plot([sReal sReal],[0 20],'k-')
    end
    title('Espectrograma filtrado')
    
    subplot(2,3,5)
    plot(m,Evn)
    hold on
    plot(m,vn)
       plot(m,SE)
    legend('Ev','v','SE')
    if isSReal==1
        plot([sReal sReal],[0 1],'k-')
    end
    title('Energía normalizada')
    
    subplot(2,3,3);
    plot(m,y,'y');
        hold on;
    plot(m,y_f,'r');
    plot(m(imS),y_f(imS),'*r')
    if isSReal==1
        plot([sReal sReal],[0 1],'k-')
    end
    title('\rho')
    legend('\rho','\rho filt','S calc')
    
    subplot(2,3,6);
    plot(m,y_pp2,'c');
    hold on;
    plot(m,y_pp,'b');
    plot(   m(imS),y_pp(imS),'*r');
    if isSReal==1
        plot([sReal sReal],[-1 1],'k-')
    end
    legend('\rho''','\rho'' filt','S calc')
    title(' derivado') 
    %}
   %%{
    figure;
    subplot(2,1,1)
    plot(m,y,'lineWidth',1)
    hold on
    plot(m,y_f,'lineWidth',2)
    legend('\rho','\rho_g','Location','Northwest','Interpreter','latex')
    xlim([4.5 8.5])
          ylabel('Normalized Amplitude','Interpreter','latex')
             set(gca,'XTick',5:8)
                   title('(a)','Interpreter','latex')
    grid minor
    %{
    subplot(3,1,2)
    plot(m,SE)
    hold on
    plot(m,y_p)
      plot(m,SE_g)
    legend('SE','\rho_g''','SE_g')
    %}
    subplot(2,1,2)
    plot(m,SE_d,'lineWidth',1)
    hold on
    plot(m,y_pp,'lineWidth',2)
    legend('\rho''''','\rho_g''''','Interpreter','latex')
    xlabel('Time [s]','Interpreter','latex')
      ylabel('Normalized Amplitude','Interpreter','latex')
      xlim([4.5 8.5])
            title('(b)','Interpreter','latex')
                   set(gca,'XTick',5:8)
      grid minor
    %}
    
    %{
    figure;
    subplot(2,1,1)
    plot(t,senal,'lineWidth',1)
    hold on
    plot(t(iS),senal(iS),'ko','lineWidth',1.5)
    legend('Signal','S wave arrival','Interpreter','latex')
      ylabel('Normalized Amplitude','Interpreter','latex')
      xlim([4.5 8.5])
                   set(gca,'XTick',5:8)
                   title('(a)','Interpreter','latex')
    grid minor
    subplot(2,1,2)
    plot(m,y_pp_n,'lineWidth',1)
    hold on
    plot(m(imS),y_pp_n(imS),'ko','lineWidth',1.5)
    legend('\rho_g''''','Maximum Value','Interpreter','latex')
    xlabel('Time [s]','Interpreter','latex')
      ylabel('Normalized Amplitude','Interpreter','latex')
      xlim([4.5 8.5])
      title('(b)','Interpreter','latex')
                   set(gca,'XTick',5:8)
      grid minor
    %}
end

end

