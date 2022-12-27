function [evento] = readDB(t1,estacion)
javaaddpath('\usgs.jar');


disp(estacion)
%estaciones=['FRE';'FU2';'LBN';'PLA';'SHG'];%'CHS'];%LBN %(los baños)
dt=datenum(0,0,0,0,1,0); % un minuto
tfin=t1+dt; 
tini=t1;
cont=1;

% Cálculo del espectrograma
K = 1024; % NFFT (cantidad de bandas de frecuencia en que se descompone la señal
L = 200;% Largo de la ventana para generar el espectrograma (2 segs = 200 muestras)
tau = 195;% Muestras de traslape
fs = 100; % frecuencia de muestreo 100 Hz
%load butterworth08_20.mat;
eventos=[];
registro=[];

addpath('rsoto92\Source')
%for l=1:length(estaciones)
%  f = SQLframeV2(datenum(tini), datenum(tfin),2,3,0,9,estacion);
f = SQLframeV2(datenum(tini), datenum(tfin),2,3,0,9,estacion);

evento.data=f.data;
evento.time=f.time;
evento.raw=f.raw;
evento.esta=estacion;
evento.coda=f.fin;
% 2 filtro 2-12 Hz
% 3 Segmentado ventana rectangular 300 muestras 1m 3 es harto mas
% 0 LTA
% 9 Seleccion detector

close all;
%end
end

