function [ iP, senal] = ondaP( varargin)
%ondaP detecta el arribo de la onda P de una señal sísmica entregando 
%el índice de la señal.
%   iP=ondaP(signal) asume frec. muestreo 100Hz
%   iP=ondaP(signal,timeVector) utiliza el vector de tiempo
%   iP=ondaP(signal,timeVector,plotFlag) con 1 para mostrar figuras
%   iP=ondaP(signal,timeVector,plotFlag,sRealTime) tiempo real de P 
%   iP=ondaP(signal,timeVector,plotFlag,sRealTime,parameters) wl,ws,li
%   See also ondaS, PREPRO, STALTA.
senal=varargin{1};
N=length(senal);
switch nargin
    case 1
        t=0:.01:(N-1)/100;
        showplots=0;
        isPReal=0;
        eje=1;
    case 2
        t=varargin{2};
        showplots=0;
        isPReal=0;
        eje=1;
    case 3
        t=varargin{2};
       showplots=varargin{3};
        isPReal=0;
        eje=1;
    case 4
        t=varargin{2};
        showplots=varargin{3};
        pReal=varargin{4};
        if isempty(pReal) || pReal==0
            isPReal=0;
        else
                isPReal=1;
        end
        eje=1;
    case 5
        t=varargin{2};
        showplots=varargin{3};
        isPReal=1;
        pReal=varargin{4};
        inputs=varargin{5};
end


if isPReal==1
    [~,iP_real]=min(abs(t-pReal));
end
if nargin==5
    
    ws=inputs(1);
    wl=inputs(2);
    lim_inf=inputs(3);
    
else
    ws=400; %ventana corta
    wl=400; %ventana larga
   % ws=200;
    lim_inf=.05; %evita máximos cuando tiende a cero
end


%% Filtro energía
%%{
senal_raw=senal;
fs=100;
nsc=50;
nov = nsc-1;
nff = 1024;
[X,~,~]=spectrogram(senal,nsc,nov,nff,fs);
S=(abs(X').^2);
Smin=min(min(S));
Smax=max(max(S));
Sn=(S-Smin)/(Smax-Smin);
u=mean2(Sn);
B=Sn>=u;
X2=B'.*X;
senal=invspecgram(X2,nff,fs,nsc,nov);
senal=senal/max(abs(senal));



%}

%%STM/LTM

for i=wl+1:N-ws
    %{
    sortedS=sort(abs(senal(i:i+ws)));
    sortedL=sort(abs(senal(i-wl:i)));
    ValIzq(i)=mean(sortedL(floor(.85*wl):floor(.9*wl)));
    ValDer(i)=mean(sortedS(floor(.85*ws):floor(.9*ws)));
    %}

    ValIzq(i)=max(abs(senal(i-wl:i)));
    ValDer(i)=max(abs(senal(i:i+ws)));
end

if isempty(i)
    
    iP=0;
else
if max(ValIzq)>0
ValIzq=ValIzq./max(ValIzq);
end
ValDer=ValDer./max(ValDer);
ValIzq(ValIzq<lim_inf)=lim_inf;



xx=ValDer./ValIzq;
xx=xx./(max(abs(xx))); %razón


iP = find(xx==max(max(xx)),1,'last');

tP=t(iP);
end


if showplots==1
  %{
    figure;
    % fi=figure;
    subplot(2,2,[1 3]);
    plot(t,senal);
    hold on
    wxx1=iP-wl;
    if wxx1<1
        wxx1=1;
    end
    wxx2=iP;
    wxx3=iP+ws;
    wy1=-max(abs(senal(wxx1:wxx2)));
    wy2=max(abs(senal(wxx2:wxx3)));
    
    plot([t(wxx1) t(wxx1) t(wxx2) t(wxx2)],[0 wy1 wy1 0],'g-','lineWidth',1.5)
    plot([t(wxx2) t(wxx2) t(wxx3) t(wxx3)],[0 wy2 wy2 0],'r-','lineWidth',1.5)
    
    
    if isPReal==1
        plot([pReal pReal],[-1 1],'k-','lineWidth',1.5)
    end
    legend('Señal','Ventana larga (previa)','Ventana corta (posterior)','Real')
    
    subplot(2,2,2);
    plot(ValIzq,'g');
    title('Valores máximos de ventanas')
    hold on;
    plot(ValDer,'r');
    
    plot([iP iP],[0 1],'c-');
    if isPReal==1
        plot([iP_real iP_real],[0 1],'k-');
    end
    legend('LTM','STM','P calculada','P Real')
    subplot(2,2,4);
    plot(xx);
    title('STM/LTM')
    hold on
    plot(iP,xx(iP),'mo');
    
    if isPReal==1
        plot([iP_real iP_real],[0 1],'k-');
    end
    
    legend('Curva','Real','P calculada','P Real')
    if isPReal==1
        dif=abs(iP-iP_real)/100;
        ee=['ONDA P - error de ' num2str(dif) '[s]'];
        suptitle(ee);
    end
    %}
    
    %% Plots windows
    %{
    figure;
        plot(t,senal);
    hold on
    wxx1=iP-wl;
    if wxx1<1
        wxx1=1;
    end
    wxx2=iP;
    wxx3=iP+ws;
    wy1=-max(abs(senal(wxx1:wxx2)));
    wy2=max(abs(senal(wxx2:wxx3)));
    plot([t(wxx2) t(wxx2) t(wxx3) t(wxx3)],[0 wy2 wy2 0],'g--','lineWidth',1.5)
    plot([t(wxx1) t(wxx1) t(wxx2) t(wxx2)],[0 wy1 wy1 0],'r--','lineWidth',1.5)
    plot(t(wxx2),0,'ko','lineWidth',1.5);
    
    grid minor;
    
    xlabel('Time [s]','Interpreter','latex');
    ylabel('Normalized Amplitude','Interpreter','latex');
    legend('Signal','STM window','LTM window','P wave arrival','Location','Northwest','Interpreter','latex')
%}

%% Plots filtro energía
%%{

fi=figure;
a1=subplot(2,1,1);
plot(senal_raw);
ylim([-.3 .3])
grid minor;
ylabel('Normalized Amplitude','Interpreter','latex');
legend('Signal','Location','Northwest','Interpreter','latex')
      title('(a)','Interpreter','latex')
a2=subplot(2,1,2);
plot(senal)
ylim([-.3 .3])
grid minor;
xlabel('Time [s]','Interpreter','latex');
ylabel('Normalized Amplitude','Interpreter','latex');
legend('Signal after EF','Location','Northwest','Interpreter','latex')
      title('(b)','Interpreter','latex')
%legend('Signal','Signal after EF','Location','Northwest','Interpreter','latex')
%}

%% Plots STM LTM y división

%{
ValIzq_=ValIzq(t>=5 & t<15);
ValDer_=ValDer(t>=5 & t<15);
xx_=xx(t>=5 & t<15);
t_=t(t>=5 & t<15)-5;



fi=figure;
subplot(2,1,1);
plot(t_,ValDer_,'g','lineWidth',1.5);
hold on;
plot(t_,ValIzq_,'r','lineWidth',1.5);
legend('STM','LTM','Location','Northwest','Interpreter','latex')

%ylim([-.5 .5])
grid minor;
ylabel('Normalized Amplitude','Interpreter','latex');
      title('(a)','Interpreter','latex')
subplot(2,1,2);
plot(t_,xx_,'lineWidth',1.5)
hold on
plot(t_(iP-500),xx_(iP-500),'ko','lineWidth',1.5);
%ylim([-.5 .5])
grid minor;
xlabel('Time [s]','Interpreter','latex');
ylabel('Normalized Amplitude','Interpreter','latex');
legend('STM/LTM','P wave arrival','Location','Northwest','Interpreter','latex')
      title('(b)','Interpreter','latex')
%legend('Signal','Signal after EF','Location','Northwest','Interpreter','latex')
%}


end

end

